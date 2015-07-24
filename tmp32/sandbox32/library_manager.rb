require 'active_support/all'
require 'pry'

require_relative 'author.rb'
require_relative 'book.rb'
require_relative 'published_book.rb'
require_relative 'reader.rb'
require_relative 'reader_with_book.rb'
# =======================================================================================================
# Класс LibraryManager теперь должен обслуживать много книг и читателей. 
# 
# У читателя м.б. одна книга в один момент времени
# Результаты всех финансовых расчетов предоставлять в центах - округлять нужно с помощью #round , 
#    но как можно позже
# Время теперь учитывается с точностью до сотой доли часа. Т.е. три часа и пятнадцать минут 
#    представляюются в виде 3.25 - и т.д. по аналогии. Правило - то же: округляем с помощью #round(2) 
#    перед самым выводом результата
# Разницу в годах считаем в пользу библиотеки: возраст книги, изданой в 2015 году сразу равняется одному году.
#    2014 год изания дает два года возраста. Таким образом, возраст книги изданой в 1996 году - 20 лет.
# =======================================================================================================

class LibraryManager

  attr_accessor :readers, :books, :readers_with_books

  def initialize readers = [], books = [], readers_with_books = []
    @readers_with_books = readers_with_books
    @readers = readers
    @books = books
    @statistics = {}
    populate_statistics!
  end

  def new_book author, title, price, pages_quantity, published_at
    @books |= [PublishedBook.new(author, title, price, pages_quantity, published_at)]
  end

  def new_reader  name, reading_speed
    @readers |= [Reader.new(name, reading_speed)]
  end

  def give_book_to_reader reader_name, book_title
    reader=@readers.find{|r| r.name == reader_name }
    book=@books.find{|r| r.title == book_title }
    unless reader.blank? or book.blank?
      @readers_with_books |= [ReaderWithBook.new(book, reader, 0, (DateTime.now.new_offset(0) + 10.days))]
      @readers-=[reader]
      @books-=[book]
      populate_statistics!
    end
  end

  def read_the_book reader_name, duration
    ReaderWithBook.find_reader_and_update_current_page(@readers_with_books, reader_name, duration)
    populate_statistics!
  end

  def reader_notification name
    rwb=@readers_with_books.find{|r| r.reader.name == name }
"Dear #{name}!
You should return a book \"#{rwb.amazing_book.title}\" authored by #{rwb.amazing_book.author.name} in #{rwb.hours_to_deadline} hours.
Otherwise you will be charged $#{rwb.penalty_per_hour} per hour.
By the way, you are on #{rwb.current_page} page now and you need #{rwb.time_to_finish} hours to finish reading \"#{rwb.amazing_book.title}\"
"
  end

  def librarian_notification
<<-TEXT
Hello,
There are #{@books.count+@readers_with_books.count} published books in the library.
There are #{@readers.count+@readers_with_books.count} readers and #{@readers_with_books.count} of them are reading the books.
#{ @readers_with_books.map{|rwb|
 "#{rwb.reader.name} is reading \"#{rwb.amazing_book.title}\" - should return on #{rwb.return_date.strftime("%F at %H%P")} - #{rwb.time_to_finish} hours of reading is needed to finish.\n"
}.join("")}
TEXT
  end

  def statistics_notification
authors=(@books.map{|i| i.author.name} | @readers_with_books.map{|i| i.amazing_book.author.name}).count
mpa=@statistics["authors"].max_by{|k,v| v["pages"]}
mpr=@statistics["readers"].max_by{|k,v| v["pages"]}
mpb=@statistics["book_titles"].max_by{|k,v| v["reading_hours"]}
"Hello,
The library has: #{@books.count+@readers_with_books.count} books, #{authors} authors, #{@readers.count+@readers_with_books.count} readers
The most popular author is #{mpa[0]}: #{mpa[1]['pages']} pages has been read in #{mpa[1]['books']} books by #{mpa[1]['readers'].count} readers.
The most productive reader is #{mpr[0]}: he had read #{mpr[1]['pages']} pages in #{mpr[1]['books']} books authored by #{mpr[1]['authors'].count} authors.
The most popular book is \"#{mpb[0]}\" authored by #{mpb[1]['author']}: it had been read for #{mpb[1]['reading_hours']} hours by #{mpb[1]['readers'].count} readers.
"
  end
 
  def current_statistics
    @statistics
  end
 
  private

  def reader_notification_params 
    
  end

  def librarian_notification_params

  end

  def statistics_notification_params

  end

  def populate_statistics!
    @statistics["readers"] = {}
    @statistics["book_titles"] = {}
    @statistics["authors"] = {}
    readers_with_books.each do |r|
      @statistics["readers"][r.reader.name] ||= {"pages" => 0, "books" => 0, "authors" => []}
      @statistics["readers"][r.reader.name]["pages"] += r.current_page
      @statistics["readers"][r.reader.name]["authors"] |= [r.amazing_book.author.name]
      @statistics["readers"][r.reader.name]["books"] += 1
      @statistics["book_titles"][r.amazing_book.title] ||= {
      "author" => "", "reading_hours" => 0, "readers" => []}
      @statistics["book_titles"][r.amazing_book.title]["author"] = r.amazing_book.author.name
      @statistics["book_titles"][r.amazing_book.title]["reading_hours"] += r.reading_hours
      @statistics["book_titles"][r.amazing_book.title]["readers" ] |= [r.reader.name]
      @statistics["authors"][r.amazing_book.author.name] ||= {"pages" => 0, "books" => 0, "readers" => []}
      @statistics["authors"][r.amazing_book.author.name]["pages"] += r.current_page
      @statistics["authors"][r.amazing_book.author.name]["readers"] |= [r.reader.name]
      @statistics["authors"][r.amazing_book.author.name]["books"] += 1
    end    
    @statistics
  end

  def statiscs_sample
    {
      "readers" => {
        "Ivan Testenko" => {
          "pages" => 1040, 
          "books" => 3, 
          "authors" => ["David A. Black", "Leo Tolstoy"]
          }
        },
      "book_titles" => {
        "The Well-Grounded Rubyist" => {
          "author" => "David A. Black", 
          "reading_hours" => 123, 
          "readers" => ["Ivan Testenko"]
          }
        },
      "authors" => {
        "Leo Tolstoy" => {
          "pages" => 123, 
          "readers" => 4, 
          "books" => 3
          }
        }
    }
  end

end

leo_tolstoy= Author.new(1828, 1910, 'Leo Tolstoy' ) 
war_and_peace=PublishedBook.new(leo_tolstoy, 'War and Peace', 1400, 3280, 1996) 
ivan=Reader.new('Ivan Testenko', 16)
ivan_testenko= ReaderWithBook.new(war_and_peace, ivan, 328, (DateTime.now.new_offset(0) + 36.hours)) 

manager=LibraryManager.new([],[], [ivan_testenko])

    manager.new_book(Author.new(1783, 1942, 'Stendhal'), 'Red and Black', 857, 400, 2001) 
    manager.new_book(Author.new(1950, 2999, 'David A. Black'), 'The Well-Grounded Rubyist', 2734, 520, 2014) 
    manager.new_book(Author.new(1950, 2999, 'David A. Black'), 'Ruby for Rails', 3599, 532, 2006) 
    manager.new_book(Author.new(1854, 1900, 'Oscar Wilde'), 'The Picture of Dorian Gray', 210, 254, 1993) 
    manager.new_reader('Barak Obama', 18)
    manager.new_reader('Vasiliy Pupkin', 12)
    manager.new_reader('Michael Saakashvili', 22)
    manager.new_reader('Goga Gopnik', 3)
    manager.new_reader('Sviatoslav Vakarchuk', 25)
    manager.give_book_to_reader('Vasiliy Pupkin','Red and Black') 
    manager.give_book_to_reader('Barak Obama','The Well-Grounded Rubyist') 
    manager.give_book_to_reader('Goga Gopnik','Ruby for Rails') 
    manager.read_the_book('Vasiliy Pupkin',30)
    manager.read_the_book('Barak Obama',27)
    manager.read_the_book('Goga Gopnik',55)
    puts "\n"+manager.reader_notification(ivan.name)
    puts "\n"+manager.librarian_notification
    puts "\n"+manager.statistics_notification
    #puts "\n"+manager.current_statistics.inspect