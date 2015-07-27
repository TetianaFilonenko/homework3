class ReaderWithBook
  attr_accessor :amazing_book, :current_page, :reader, :return_date

  def initialize  amazing_book, reader, current_page = 0, return_date = (Time.now.utc + 2.weeks)
    @amazing_book = amazing_book
    @reader = reader
    @return_date = return_date
    @current_page = current_page
  end

  def hours_until_return
    (@return_date.to_time.to_f - Time.now.utc.to_f) / 3600
  end

  def hours_to_finish
    (amazing_book.pages_quantity - current_page) / reader.reading_speed.to_f
  end

  # def penalty_until_return
  #   @amazing_book.penalty_per_hour * hours_until_return
  # end

  def penalty_to_finish
    @amazing_book.penalty_per_hour * hours_to_finish
  end

  def days_to_buy

  end

  def read_the_book! duration

  end

end
