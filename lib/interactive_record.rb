require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    sql = "PRAGMA table_info('#{table_name}')"
    column_data = DB[:conn].execute(sql)
    column_data.map {|column| column['name']}.compact
  end

  def initialize(attributes={})
    attributes.each {|key, value| self.send("#{key}=", value)}
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_no_id
    self.class.column_names.delete_if {|col_name| col_name == 'id'}
  end

  def col_names_for_insert
    col_names_no_id.join(', ')
  end

  def values_for_insert
    col_names_no_id.map {|col_name| "'#{self.send(col_name)}'"}.join(', ')
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{table_name} WHERE name = ?"
    DB[:conn].execute(sql, name)
  end

  def self.find_by(attribute)
    sql = "SELECT * FROM #{table_name} WHERE #{attribute.keys[0].to_s} = '#{attribute.values[0]}'"
    DB[:conn].execute(sql)
  end

end
