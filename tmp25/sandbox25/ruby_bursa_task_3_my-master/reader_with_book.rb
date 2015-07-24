class ReaderWithBook
  attr_accessor :book, :current_page, :reader, :return_date

  def initialize  book, reader, return_date = (Time.now + 2.weeks), current_page = 0 
    @book = book
    @reader = reader
    @return_date = return_date
    @current_page = current_page
    @book.reader = @reader
  end

  def time_to_finish
    ((@book.pages_quantity - @current_page) / @reader.reading_speed.to_f).round(1)
  end

  def penalty_to_finish 
    current = DateTime.now.new_offset(0)
    return 0 if @book.price <= 0 || @book.pages_quantity <= 0 || @current_page <= 0 || (@book.pages_quantity - @current_page) <= 0

    #Нужно на прочтение в секундах
    left_seconds = time_to_finish * 3600

    #Дата завршения чтения
    left_time = current.to_time + left_seconds

    return 0 if @return_date >= left_time

    #Сколько часов перечитывает с момента сдачи
    total_hours = (left_time - @return_date.to_time).to_i / 3600

    #тоговая пеня за превышение даты сдачи
    total_peny = (total_hours * @book.price_per_hour).round
  end

#  def penalty
#    @book.penalty_per_hour * hours_overdue
#  end
# Hours to deadline
  def hours_to_deadline(current = Time.now)
    current > @return_date ? 0 : (@return_date.to_time - current.to_time) / 3600.0
  end

  def days_to_buy
  end

  def read_the_book! duration
    @book.update_info(@reader.name, duration * @reader.reading_speed, duration)    
    @current_page = @current_page + duration * @reader.reading_speed
  end

#  def self.find_reader_and_update_current_page readers_with_books, name, duration
#    readers_with_books.find{|r| r.reader.name == name}.read_the_book!(duration)
#  end

end
