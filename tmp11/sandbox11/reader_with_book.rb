class ReaderWithBook
attr_accessor :amazing_book, :reader, :current_page, :return_date
def initialize amazing_book, reader, current_page = 0, return_date = (Time.now + 2.weeks)
@amazing_book = amazing_book
@reader = reader
@current_page = current_page
@return_date = return_date
end

def penalty_per_hour
    price_penalty = amazing_book.price * 0.0005
    pages_penalty = 0.000003 * amazing_book.price * amazing_book.pages_quantity
    age_penalty = 0.00007 * amazing_book.price * amazing_book.age

    (price_penalty + pages_penalty + age_penalty).round
  end

def self.find_reader_and_update_current_page array, name, duration
array.find{|r| r.name == name }.read_the_book!(duration)
end
def reading_hours
(current_page.to_f / reader.reading_speed).round(2)
end
def time_to_finish
((amazing_book.pages_quantity - current_page) / reader.reading_speed.to_f).round(2)
end
def penalty
amazing_book.penalty_per_hour * hours_overdue
end
def hours_overdue
(Time.now.to_i - issue_datetime.to_time.to_i) / 3600.0
end
def days_to_buy
end
def read_the_book! duration
self.current_page = current_page + duration * reader.reading_speed
end
def penalty_to_finish
end

end
