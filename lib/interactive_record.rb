require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

    def self.table_name
        self.to_s.downcase.pluralize
    end

    def self.column_names
       sql = <<-SQL
            PRAGMA table_info(#{self.table_name})
            SQL
        schema = DB[:conn].execute(sql)    
        cn = []
         schema.each{|column| cn << column["name"]} 

        cn.compact   
    end

    def attr_accessor
        self.class.column_names.each do |column_name| 
            attr_accessor column_name.to_sym
        end
    end

    def initialize(options={})
        options.each do |prop, value|
            self.send("#{prop}=", value)
        end
    end

    def col_names_for_insert
      self.class.column_names[1..-1].join(",")     
    end

    def values_for_insert
       #what to return? a string of those values (vals.join(","))
       vals = []
       #iterate thru the column names to send each column the value of an attr 
       self.class.column_names.each do |cn|
         vals << "#{send(cn)}" if !send(cn).nil?
       end
       vals.join(", ")
    end

    def table_name_for_insert
        self.class.table_name
    end

    def save
        sql = <<-SQL
                INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
                VALUES (?)
                SQL
        DB[:conn].execute(sql, [values_for_insert])
        @id = DB[:conn].execute("SELECT * FROM #{table_name_for_insert}")[0][0]
    end

    def self.find_by_name
        DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE name = ?", [self.name])[0]
    end

    def self.find_by
        DB[:conn].execute("SELECT * FROM #{self.table_name} WHERE #{column_names[i].to_s} = ?", [self.column_names[i].to_s])[0] 
    end
  
end