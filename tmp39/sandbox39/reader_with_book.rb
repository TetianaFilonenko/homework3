class ReaderWithBook
  attr_accessor :amazing_book, :current_page, :reader, :return_date

  def initialize  amazing_book, reader, current_page = 0, return_date = (Time.now + 2.weeks)
    @amazing_book = amazing_book
    @reader = reader
    @return_date = return_date
    @current_page = current_page
  end
  
  def self.find_reader_and_update_current_page array, name, duration
    pages = 0
    reader_with_book = array.find{|r| r.reader.name == name }
    if reader_with_book != nil
      pages = reader_with_book.read_the_book!(duration)
    end
    [reader_with_book, pages]
  end

  def self.find_reader_with_books readers_with_books, reader_name
    books = []
    readers_with_books.each do |reader_with_book|
       if reader_with_book.reader.name == reader_name
         books << reader_with_book
       end
    end
    books
  end 

  def self.find_readers readers_with_books
    readers = []
    readers_with_books.each do |reader_with_book|
       readers << reader_with_book.reader
    end
    readers.uniq
  end

  def reading_hours page = @current_page
    (page.to_f / reader.reading_speed).round(2)
  end

  def time_to_finish
    (amazing_book.pages_quantity - current_page) / Float(reader.reading_speed)
  end

  def penalty
    (amazing_book.penalty_per_hour * hours_overdue).round
  end

  def hours_overdue
    ((Time.now.to_i - return_date.to_time.to_i) / 3600.0).round 2
  end

  def days_to_buy
    price = amazing_book.price
    return 0 if price <= 0
     
    date_now = DateTime.now.new_offset( 0 )
    hours_total = 0
    date_beginning = date_now    
    days = 0
    loop do
      year = date_beginning.year      
      date_end = DateTime.new(year, 12, 31, 23, 59, 59).new_offset( 0 )
      
      hours_total = ((date_end.to_time - date_beginning.to_time).to_i / 3600.0) + hours_total
      penalty_hour = amazing_book.penalty_per_hour date_beginning.year 
     
      hours_for_reading = price / penalty_hour 

      if hours_total >= hours_for_reading
        days = (hours_for_reading / 24).round
        break
      else
         date_beginning = DateTime.new(year + 1).new_offset( 0 )
      end
    end 
    days
  end

  def read_the_book! duration
    pages = (duration * reader.reading_speed).to_i 
    self.current_page = current_page + pages
    if self.current_page > amazing_book.pages_quantity
      pages = amazing_book.pages_quantity - (self.current_page - pages) 
      self.current_page = amazing_book.pages_quantity
    end
    pages
  end

  def penalty_to_finish
    price = amazing_book.price
    return 0 if reader.reading_speed <= 0 || price <= 0

    time_when_read = DateTime.now.new_offset( 0 ).to_time + (time_to_finish * 3600)
    time_return = return_date.utc.to_time
 
    if time_when_read > time_return
      hours = ((time_when_read - time_return).to_i / 3600.0).round 2
      
      penalty_per_hour = amazing_book.penalty_per_hour time_when_read.year
      (penalty_per_hour * hours).round
    else
      penalty = 0
    end
  end

  def hours_to_return 
    ((return_date.to_time.to_i - Time.now.to_i) / 3600.0).round 2
  end

end
