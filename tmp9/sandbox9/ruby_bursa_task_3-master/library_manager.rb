require 'active_support/all'
require 'pry'

require_relative 'author.rb'
require_relative 'book.rb'
require_relative 'published_book.rb'
require_relative 'reader.rb'
require_relative 'reader_with_book.rb'

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

  end

  def new_reader  name, reading_speed

  end

  def give_book_to_reader reader_name, book_title

  end

  def read_the_book reader_name, duration
    ReaderWithBook.find_reader_and_update_current_page(@readers_with_books, reader_name, duration)
  end

  def reader_notification name = "Ivan Testenko"
    reader = readers_with_books.find(|r| r.reader.name == name)
      <<-TEXT
Dear #{r.name}!

You should return a book "#{r.amazing_book.title}" authored by #{r.amazing_book.author.name} in 36 hours.
Otherwise you will be charged $12.3 per hour.
By the way, you are on 333 page now and you need 5.4 hours to finish reading "War and Peace"
TEXT
  end

  def librarian_notification
      <<-TEXT
Hello,

There are #{books.count = readers_with_books.count} published books in the library.
There are #{readers.count = readers_with_books.count} readers and #{readers_with_books.count} of them are reading the books.

Ivan Testenko is reading "War and Peace" - should return on 2015-07-04 at 10am - 5.0 hours of reading is needed to finish.
Vasiliy Pupkin is reading "Red and Black" - should return on 2015-07-12 at 7pm  - 12.7 hours of reading is needed to finish.
Barak Obama is reading "The Well-Grounded Rubyist" - should return on 2015-07-10 at 12pm  - 44.5 hours of reading is needed to finish.
TEXT

  end

  def statistics_notification
      <<-TEXT
Hello,

The library has: #{readers.count = readers_with_books.count} books, #{authors_with_books.count} authors, #{readers_with_books.count} readers
The most popular author is Leo Tolstoy: 2450 pages has been read in 2 books by 4 readers.
The most productive reader is Ivan Testenko: he had read 1040 pages in 3 books authored by 3 authors.
The most popular book is "The Well-Grounded Rubyist" authored by David A. Black: it had been read for 123.0 hours by 5 readers.
TEXT
  end

  private

  def reader_notification_params name = "Ivan Testenko"

  end

  def librarian_notification_params


  end

  def statistics_notification_params

  end

  def populate_statistics!
    readers_with_books.each do |r|
      @statistics["readers"][r.reader.name] ||= {"pages" => 0, "books" => 0, "authors" => []}
      @statistics["readers"][r.reader.name]["pages"] += r.current_page
      @statistics["readers"][r.reader.name]["authors"] |= [r.amazing_book.author.name]
      @statistics["readers"][r.reader.name]["books"] += 1
      @statistics["book_titles"][r.amazing_book.title] ||= {
      "author" => "", "reding_hours" => 0, "readers" => []}
      @statistics["book_titles"][r.amazing_book.title]["author"] = r.amazing_book.author.name
      @statistics["book_titles"][r.amazing_book.title]["reading_hours"] += r.reading_hours
      @statistics["book_titles"][r.amazing_book.title]["readers" ] |= [r.reader.name]
      # @statistics["authors"][r.name] ||= {"pages" => 0, "books" => 0, "authors" => 0}
      # @statistics["authors"][r.name]["pages"] += r.current_page
      # @statistics["authors"][r.name]["authors"] |= [r.amazing_book.author.name]
      # @statistics["authors"][r.name]["books"] += 1
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

  leo_tolstoy = Author.new(1828, 1910, 'Leo Tolstoy' ) 
  oscar_wilde = Author.new(1854, 1900, 'Oscar Wilde') 
  war_and_peace =PublishedBook.new(leo_tolstoy, 'War and Peace', 1400, 3280, 1996) 
  dorian_book =PublishedBook.new(oscar_wilde, 'Portrait of Dorian Grey', 1200, 800, 2012) 
  ivan = Reader.new('Ivan Testenko', 16)
  obama = Reader.new('Barak Obama', 16)
  ivan_testenko = ReaderWithBook.new(war_and_peace,ivan, 328, (DateTime.now.new_offset(0) + 2.days)) 
  manager =  LibraryManager.new([],[], [ivan_testenko]) 


  puts manager.reader_notification(ivan.name)
  puts manager.librarian_notification(ivan.name)
  puts manager.statistics_notification(ivan.name)