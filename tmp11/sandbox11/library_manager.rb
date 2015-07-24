require 'active_support/all'
require 'pry'

require_relative 'author.rb'
require_relative 'book.rb'
require_relative 'published_book.rb'
require_relative 'reader.rb'
require_relative 'reader_with_book.rb'

class LibraryManager

  attr_accessor :readers, :books, :readers_with_books

  def initialize readers = [], books = [], *readers_with_books 
    @readers_with_books = readers_with_books
    @readers = readers
    @books = books
    #@statistics_hash = {}
    #populate_statistics!
  end

  def new_book(author, title, price, pages_quantity, published_at)

  end

  def new_reader(name, reading_speed)

  end

  def give_book_to_reader(reader_name, book_title)

  end

  def read_the_book(reader_name, duration)
    ReaderWithBook.find_reader_and_update_current_page(@readers_with_books, reader_name, duration)

  end

  def reader_notification(name)
    <<-TEXT
Dear #{reader_notification_params[:reader_name]}!
You should return a book "#{reader_notification_params[:book_title]}" authored by #{reader_notification_params[:book_author]} in #{reader_notification_params[:return_date]} hours.
Otherwise you will be charged #{reader_notification_params[:penalty_per_hour]} per hour.
By the way, you are on #{reader_notification_params[:current_page]} page now and you need #{reader_notification_params[:hours_to_finish]} hours to finish reading "#{reader_notification_params[:book_title]}"
    TEXT

  end

  def librarian_notification
   <<-TEXT
Hello,
There are #{librarian_notification_params[:total_books]} published books in the library.
There are #{librarian_notification_params[:total_readers]} readers and #{librarian_notification_params[:readers_are_reading]} of them are reading the books.
#{reader_notification_params[:reader_name]} is reading "#{reader_notification_params[:book_title]}" - should return on 2015-07-04 at 10am - 5.0 hours of reading is needed to finish.
Vasiliy Pupkin is reading "Red and Black" - should return on 2015-07-12 at 7pm - 12.7 hours of reading is needed to finish.
Barak Obama is reading "The Well-Grounded Rubyist" - should return on 2015-07-10 at 12pm - 44.5 hours of reading is needed to finish.
TEXT
  end

  def statistics_notification
    <<-TEXT
Hello,
The library has: #{statistics_notification_params[:total_books]} books, 4 authors, #{statistics_notification_params[:total_readers]} readers
The most popular author is Leo Tolstoy: 2450 pages has been read in 2 books by 4 readers.
The most productive reader is Ivan Testenko: he had read 1040 pages in 3 books authored by 3 authors.
The most popular book is "The Well-Grounded Rubyist" authored by David A. Black: it had been read for 123.0 hours by 5 readers.
TEXT

  end

  private

  def reader_notification_params
    {
    reader_name: readers_with_books[0].reader.name,
    book_title: readers_with_books[0].amazing_book.title,
    book_author: readers_with_books[0].amazing_book.author,
    return_date: (readers_with_books[0].return_date.to_i - Time.now.to_i) / 3600.0,
    penalty_per_hour: readers_with_books[0].penalty_per_hour,
    current_page: readers_with_books[0].current_page,
    hours_to_finish: readers_with_books[0].time_to_finish
  }


  end

  def librarian_notification_params
    {
      total_books: @books.length,
      total_readers: @readers.length,
      readers_are_reading: @readers_with_books.length,
    }

  end

  def statistics_notification_params
    {
      total_books: @books.length,
      total_readers: @readers.size,
    }

  end
=begin
  def populate_statistics!
    readers_with_books.each do |r|
      @statistics["readers"][r.reader.name] ||= {"pages" => 0, "books" => 0, "authors" => 0}
      @statistics["readers"][r.reader.name]["pages"] += r.current_page
      @statistics["readers"][r.reader.name]["authors"] |= [r.amazing_book.author.name]
      @statistics["readers"][r.reader.name]["books"] += 1
      @statistics["book_titles"][r.amazing_book.title] ||= {"author" => "", "reading_hours" => 0, "readers" => []}
      @statistics["book_titles"][r.amazing_book.title]["author"] += r.amazing_book.author.name
      @statistics["book_titles"][r.amazing_book.title]["reading_hours"] += r.reading_hours
      @statistics["book_titles"][r.amazing_book.title]["readers"] |= [r.reader.name]
      @statistics["authors"][r.amazing_book.author] ||= {"pages" => 0, "books" => 0, "authors" => 0}
      @statistics["authors"][r.amazing_book.author]["pages"] += r.current_page
      @statistics["authors"][r.amazing_book.author]["authors"] |= [r.amazing_book.author.name]
      @statistics["authors"][r.amazing_book.author]["books"] += 1
      end
    @statistics
    
  end

  def statistics_sample
    {
      "readers" => {
        "Ivan Testenko" => {
          "pages" => 1040, 
          "books" => 3, 
          "authors" => ["David A. Black", "Leo Tolstoy"]
          }
        },
      "book_titles" => {
        "The well-Grounded Rubyist" => 
        {"author" => "David A. Black", 
          "reading_hours" => 123, 
          "readers" => 5
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
=end
end