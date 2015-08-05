require 'active_support/all'
require 'pry'

require_relative 'author.rb'
require_relative 'book.rb'
require_relative 'published_book.rb'
require_relative 'reader.rb'
require_relative 'reader_with_book.rb'
#
class LibraryManager
  attr_accessor :readers, :books, :readers_with_books

  def initialize(readers = [], books = [], readers_with_books = [])
    @readers_with_books = readers_with_books
    @readers = readers
    @books = books
  end

  def get_reader_by_name(reader_name)
    readers.find { |reader| reader.name == reader_name }
  end

  def get_reader_with_book_by_name(reader_name)
    readers_with_books.find { |reader| reader.name == reader_name }
  end

  def get_book_by_title(book_title)
    books.find { |book| book.title == book_title }
  end

  def new_book(author, title, price, pages_quantity, published_at)
    books << PublishedBook.new(author,
                               title,
                               price,
                               pages_quantity,
                               published_at)
  end

  def new_reader(name, reading_speed)
    readers << Reader.new(name, reading_speed)
  end

  def give_book_to_reader(reader_name, book_title)
    book_object = get_book_by_title(book_title)
    reader_object = get_reader_by_name(reader_name)
    if book_object
      if reader_object
        readers_with_books << ReaderWithBook.new(book_object, reader_object)
      else
        puts "Can't find such reader - " + reader_name
      end
    else
      puts "Can't find such book - " + book_title
    end
  end

  def read_the_book(reader_name, duration)
    get_reader_with_book_by_name(reader_name).read_the_book!(duration)
  end

  def reader_notification reader_name
    puts "
    Dear Ivan Testenko!#{get_reader_with_book_by_name(reader_name).reader.name}

You should return a book "War and Peace" #{get_book_by_title(get_reader_with_book_by_name(reader_name).amazing_book.title}  authored by Leo Tolstoy in 36 hours.
Otherwise you will be charged $12.3 per hour.
By the way, you are on 333 page now and you need 5.4 hours to finish reading "War and Peace"#{get_book_by_title(get_reader_with_book_by_name(reader_name).amazing_book.title}"
  end

  def librarian_notification
    puts "Hello,

There are 5 published books in the library.
There are 6 readers and 3 of them are reading the books.

Ivan Testenko is reading "War and Peace" - should return on 2015-07-04 at 10am - 5.0 hours of reading is needed to finish.
Vasiliy Pupkin is reading "Red and Black" - should return on 2015-07-12 at 7pm  - 12.7 hours of reading is needed to finish.
Barak Obama is reading "The Well-Grounded Rubyist" - should return on 2015-07-10 at 12pm  - 44.5 hours of reading is needed to finish."
  end

  def statistics_notification
    puts "Hello,

The library has: 5 books, 4 authors, 6 readers
The most popular author is Leo Tolstoy: 2450 pages has been read in 2 books by 4 readers.
The most productive reader is Ivan Testenko: he had read 1040 pages in 3 books authored by 3 authors.
The most popular book is "The Well-Grounded Rubyist" authored by David A. Black: it had been read for 123.0 hours by 5 readers."
  end

  private

  def reader_notification_params
  end

  def librarian_notification_params
  end

  def statistics_notification_params
  end
end

leo_tolstoy = Author.new(1828, 1910, 'Leo Tolstoy') 
oscar_wilde = Author.new(1854, 1900, 'Oscar Wilde') 

war_and_peace = PublishedBook.new(leo_tolstoy, 'War and Peace', 1400, 3280, 1996) 
dorian_gray = PublishedBook.new(oscar_wilde, 'The Picture of Dorian Gray', 580, 192, 2004) 

ivan_testenko = ReaderWithBook.new('Ivan Testenko', 16, war_and_peace, 328) 
mark_testenko =ReaderWithBook.new('Mark Testenko', 12, dorian_gray, 48) 

ivan = Reader.new(Ivan Petrovich,100)
nikolay = Reader.new(Nikolay,150)
john = Reader.new(Jonh,200)



manager = LibraryManager.new([ivan, nikolay, john],
 
                             [war_and_peace, dorian_grey,
                              fahrenheit451, dandellion_wine,
                              dandellion_wine, dandellion_wine,
                              anna_karenina, the_financier],
 
                             [ivan_testenko, vasiliev_nikolay, vasily_pupkin])

#oscar_wilde = Author.new(1854, 1900, 'Oscar Wilde')
#ukrainian_author = Author.new(1856, 1916, 'Іван Франко')

#war_and_peace = PublishedBook.new(leo_tolstoy, 'War and Peace', 1400, 3280, 1996) 
#ivan_teslenko = ReaderWithBook.new('Ivan Testenko', 16, war_and_peace, 328) 
#manager = LibraryManager.new(ivan_teslenko, (DateTime.now.new_offset(0) - 2.days)) 
#puts "Hello word!"
#p manager.penalty
#p manager.could_meet_each_other? leo_tolstoy, oscar_wilde
#p manager.days_to_buy
#p manager.transliterate ukrainian_author
#p manager.penalty_to_finish