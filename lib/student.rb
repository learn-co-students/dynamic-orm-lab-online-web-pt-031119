class Student < InteractiveRecord
   self.column_names.each do |col| 
   attr_accessor col.to_sym
  end 
end	