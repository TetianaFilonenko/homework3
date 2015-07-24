class ReaderWithBook
  attr_accessor :amazing_book, :current_page, :reader, :return_date

  def initialize  amazing_book, reader, current_page = 0, return_date = (Time.now + 2.weeks)
    @amazing_book = amazing_book
    @reader = reader
    @return_date = return_date
    @current_page = current_page
  end

  def time_to_finish
    (amazing_book.pages_quantity - current_page) / reader.reading_speed
  end

  def penalty
    amazing_book.penalty_per_hour * hours_overdue
  end

  def hours_overdue
   # (Time.now.to_i - return_date.to_time.to_i) / 3600.0
    (return_date.to_time.to_i - Time.now.to_i) / 3600.0

  end

  def days_to_buy

  penalty_per_day = amazing_book.penalty_per_hour * 24
  days = amazing_book.price / penalty_per_day
  if days>0
   return   days.round
  else
    return   0
  end



  end

  def read_the_book! duration
    self.current_page = current_page + duration * reader.reading_speed
  end

  def reading_hours
    (current_page/ reader.reading_speed).round(2)
  end

  def penalty_to_finish

    

  end

end
