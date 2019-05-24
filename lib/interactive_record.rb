require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "pragma table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    column_names = []

    table_info.each do |row|
      column_names << row["name"]
    end
    column_names.compact

  end

  def initialize(options={})
    options.each do |key,value|
      self.send("#{key}=", value)
    end
    # binding.pry
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col|col == "id"}.join(", ")
    # binding.pry
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |column|
      values << "'#{send(column)}'" unless send(column).nil?
    end
    # binding.pry
    values.join(", ")

  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)

    grab_id = "SELECT last_insert_rowid() FROM #{table_name_for_insert}"
    @id = DB[:conn].execute(grab_id)[0][0]
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = ?"
    DB[:conn].execute(sql,name)

  end

  def self.find_by(attribute)
    search_item = ""
    search_key = ""
    attribute.each do |key,value|
      search_item = value
      search_key = key
    end
    # binding.pry
    case search_key
    when :name
      sql = "SELECT * FROM #{self.table_name} WHERE name = ?"
      DB[:conn].execute(sql,search_item)
    when :grade
      sql = "SELECT * FROM #{self.table_name} WHERE grade = ?"
      DB[:conn].execute(sql,search_item)
    when :id
      sql = "SELECT * FROM #{self.table_name} WHERE ID = ?"
      DB[:conn].execute(sql,search_item.to_i)
    end



    
  end
  
end