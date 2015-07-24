class ReaderWithBook
  attr_accessor :amazing_book, :current_page, :reader, :return_date

  def initialize  amazing_book, reader, current_page = 0, return_date = (Time.now.utc + 2.weeks)
    @amazing_book = amazing_book
    @reader = reader
    @return_date = return_date
    @current_page = current_page
  end

  def time_to_finish
    1.0 * (amazing_book.pages_quantity - current_page) / reader.reading_speed
  end

  def penalty
    amazing_book.penalty_per_hour * hours_overdue
  end

  def hours_overdue
    Time.now > return_date.to_time ? (Time.now.utc.to_i - return_date.to_time.to_i) / 3600.0 : 0
  end

  def days_to_buy
    amazing_book.price / amazing_book.penalty_per_hour / 24
  end

  def read_the_book! duration
    @current_page = @current_page + duration * @reader.reading_speed
    @current_page = amazing_book.pages_quantity if @current_page > amazing_book.pages_quantity
  end

  def penalty_to_finish
    dtFinish = Time.now.utc + time_to_finish.hours
    dtFinish > return_date ? (penalty_tax(dtFinish) * reader_with_book.book.price * ((dtFinish - return_date).to_f * 24)).round(2) : 0
  end

  def reading_hours
    (current_page.to_f / reader.reading_speed).round(2)
  end

end
