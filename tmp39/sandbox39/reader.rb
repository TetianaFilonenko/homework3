class Reader
  attr_accessor :name, :reading_speed

  def initialize name, reading_speed
    @name = name
    @reading_speed = reading_speed
  end
 
  def self.find readers, reader_name
    readers.each do |reader|
       if reader.name == reader_name
         return reader
       end
    end
    nil
  end 
end
