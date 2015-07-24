class ReaderWithBook
  attr_accessor :amazing_book, :current_page, :reader, :return_date

  def initialize  amazing_book, reader, current_page = 0, return_date = (Time.now + 2.weeks)
    @amazing_book = amazing_book
    @reader = reader
    @return_date = return_date
    @current_page = current_page
  end

  def self.find_reader_and_update_current_page (readers_with_books, reader_name, duration)
    readers_with_books.find {|r| r.reader_name == reader_name}.read_the_book! duration
  end

  def reading_hours
    (current_page / reader.reading_speed.to_f).round(2)
  end

  def time_to_finish
    (amazing_book.pages_quantity - current_page) / reader.reading_speed.to_f
  end

  def penalty
    penalty = (amazing_book.penalty_per_hour * hours_overdue.round(2)).round
    if penalty < 0 
      return 0
    else 
      return penalty
    end
  end

  def book_title
    amazing_book.title
  end

  def author_name
    amazing_book.author.name
  end

  def reader_name
    reader.name
  end

  def hours_overdue
    (Time.now.to_i - return_date.to_time.to_i) / 3600.0
  end

  def days_to_buy
    (1.0 / (24.0 * amazing_book.penalty_per_hour / amazing_book.price)).ceil
  end

  def read_the_book! duration
    pages_read = duration * reader.reading_speed
    if pages_read + @current_page > amazing_book.pages_quantity
      @current_page = amazing_book.pages_quantity
    else
      @current_page += pages_read
    end
  end

  def penalty_to_finish
    penalty_to_finish = (amazing_book.penalty_per_hour * (hours_overdue + time_to_finish).round(2)).round
    if penalty_to_finish < 0 
      return 0
    else 
      return penalty_to_finish
    end
  end

end
