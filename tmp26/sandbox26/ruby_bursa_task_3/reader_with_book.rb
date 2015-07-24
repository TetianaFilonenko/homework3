class ReaderWithBook

  attr_accessor :amazing_book, :current_page, :reader, :return_date

  def initialize amazing_book, reader, current_page = 0, return_date = (Time.now + 2.weeks)
    @amazing_book, @reader, @current_page, @return_date = amazing_book, reader, current_page, return_date
  end

  def reading_speed
    reader.reading_speed
  end

  def reading_hours
    (current_page / reader.reading_speed.to_f).round(2)
  end 

  def time_to_finish
    (amazing_book.pages_quantity - current_page) / reading_speed.to_f
  end

  def penalty
    [amazing_book.penalty_per_hour * hours_overdue.round(2), 0.0].max.round
  end

  def hours_overdue
    (Time.now.to_i - return_date.to_time.to_i) / 3600.0
  end

  def days_to_buy
    (1.0 / (24.0 * amazing_book.penalty_per_hour / amazing_book.price)).ceil
  end

  def read_the_book! duration 
    self.current_page = time_to_finish > duration ? current_page + reading_speed * duration : amazing_book.pages_quantity
  end

  def penalty_to_finish
    [0, amazing_book.penalty_per_hour * (hours_overdue + time_to_finish).round(2)].max.round
  end

  def self.get_reader_and_update_current_page readers_with_books, reader_name, duration
    readers_with_books.find {|r| r.reader.name == reader_name}.read_the_book! duration
  end

end



