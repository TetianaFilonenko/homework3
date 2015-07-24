class ReaderWithBook
  attr_accessor :amazing_book, :current_page, :reader, :return_date

  def initialize  amazing_book, reader, current_page = 0, return_date = (Time.now + 2.weeks)
    @amazing_book = amazing_book
    @reader = reader
    @return_date = return_date
    @current_page = current_page
  end

  def self.find_reader_and_update_current_page array, name, duration
    array.find{|r| r.name == name }.read_the_book!(duration)
  end

  def reading_hours
    (current_page.to_f / reader.reading_speed).round(2)
  end

  def time_to_finish
    (amazing_book.pages_quantity - current_page) / reading_speed
  end

  def penalty
    amazing_book.penalty_per_hour * hours_overdue
  end

  def hours_overdue
    (Time.now.to_i - return_date.to_time.to_i) / 3600.0
  end

  def days_to_buy
    price = self.amazing_book.price
    all_pages = self.amazing_book.pages_quantity
    year_now = DateTime.now.new_offset.strftime('%Y').to_i

    year_publish = self.amazing_book.published_at
    delta_years_book = year_now - year_publish + 1

    pen_for_hour = ( 0.00007 * delta_years_book * price) + (0.000003 * all_pages * price) + (0.0005 * price)

    (price / (24 * pen_for_hour)).to_i + 1

  end

  def read_the_book! duration
    self.current_page = current_page + duration * reader.reading_speed
  end

  def penalty_to_finish
    now_datetime = DateTime.now.new_offset.strftime('%s').to_f
    old_datetime = return_date.strftime('%s').to_f
    delta_hour = (old_datetime - now_datetime) / 3600

    price = self.amazing_book.price
    pages_quantity_new = self.amazing_book.pages_quantity
    current_page_new = self.current_page
    reading_speed_new = self.reader.reading_speed
    rest_hours = (pages_quantity_new - current_page_new) / reading_speed_new

     if delta_hour > 0 
      (delta_hour - rest_hours) > 0 ? 0 : ((delta_hour - rest_hours).abs * price * 0.001).round
    else
      ((delta_hour * price * 0.001).abs + rest_hours * price * 0.001).round
    end
  end

end

