class ReaderWithBook
  attr_accessor :amazing_book, :current_page, :reader, :return_date

  def initialize  amazing_book, reader, current_page = 0, return_date = (Time.now + 2.weeks)
    @amazing_book = amazing_book
    @reader = reader
    @return_date = return_date
    @current_page = current_page
  end

  def self.find_reader_and_update_current_page array, name, duration
    array.find{|r| r.reader.name == name }.read_the_book!(duration)
  end

  def reading_hours
    (current_page.to_f / reader.reading_speed).round(2)
  end

  def time_to_finish
    k=amazing_book.pages_quantity.to_f - current_page.to_f
    k<=0 ? 0: (k / reader.reading_speed).round(2)
  end

  def penalty
    amazing_book.penalty_per_hour * hours_overdue
  end
  
  def penalty_per_hour
    (amazing_book.penalty_per_hour/100).round(2)
  end
  
  def hours_overdue
    (Time.now.to_i - return_date.to_time.to_i) / 3600.0
  end

  def days_to_buy

  end

  def read_the_book! duration
    self.current_page = current_page + duration * reader.reading_speed
  end

  def penalty_to_finish

  end

  def hours_to_deadline
    sec=return_date.strftime('%s').to_i-DateTime.now.strftime('%s').to_i
    sec<=0 ? 0 : (sec/3600).floor
  end

end
