#
class ReaderWithBook
  attr_accessor :amazing_book, :current_page, :reader, :return_date

  def initialize(amazing_book, reader, current_page = 0,
                 return_date = (Time.now + 2.weeks))
    @amazing_book = amazing_book
    @reader = reader
    @return_date = return_date
    @current_page = current_page
  end

  def time_to_finish
    (amazing_book.pages_quantity - current_page) / reading_speed
  end

  def penalty
    amazing_book.penalty_per_hour * hours_overdue
  end

  def hours_overdue
    (Time.now.to_i - issue_datetime.to_time.to_i) / 3600.0
  end

  def days_to_buy
  end

  def read_the_book!(duration)
    if time_to_finish > duration
      self.current_page = current_page + reader.reading_speed * duration
    else
      self.current_page = amazing_book.pages_quantity
    end
  end

  def penalty_to_finish
    time_to_finish * penalty
  end
end
