class ReaderWithBook
  attr_accessor :amazing_book, :current_page, :reader, :return_date

  def initialize  amazing_book, reader, current_page = 0, return_date = (Time.now + 2.weeks)
    @amazing_book = amazing_book
    @reader = reader
    @return_date = return_date
    @current_page = current_page
  end

  def self.find_reader_and_update_current_page array, name, duration
    reader = array.find{|r| r.name == name}.read_the_book!(duration)
  end
  
  def reading_hours
    (current_page.to_f / reader.reading_speed.to_f).round(2)
  end
  
  def time_to_finish
    (amazing_book.pages_quantity - current_page) / reader.reading_speed.to_f
  end

  def penalty
    (amazing_book.penalty_per_hour * hours_overdue.round(2)).round
  end

  def hours_overdue
    (Time.now.to_i - return_datetime.to_time.to_i) / 3600.0
  end

  def hours_untill_ret
    (reader_with_book.return_date.to_time.to_i - Time.now.to_i) / 3600.0
  end

  def days_to_buy
    return 0 if @price <= 0
    return (@price / price_per_hour / 24).round

  end

  def read_the_book! duration
    ReaderWithBook.current_page = current_page + duration * reader.reading_speed
    ReaderWithBook.current_page = 0 if @current_page < 0
    ReaderWithBook.current_page = amazing_book.pages_quantity if ReaderWithBook.current_page > amazing_book.pages_quantity
  end

  def penalty_to_finish
    penalty_to_finish = (amazing_book.penalty_per_hour * (hours_overdue + time_to_finish).round(2)).round

  end

end
