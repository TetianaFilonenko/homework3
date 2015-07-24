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
    @statistic = {}
    populate_statistics!
  end

  def new_book author, title, price, pages_quantity, published_at
    book = PublishedBook.new(author, title, price, pages_quantity, published_at)
    @books << book
    populate_statistics!
  end

  def new_reader  name, reading_speed
    reader = Reader.new(name, reading_speed)
    @readers << reader
    populate_statistics!
  end

  def give_book_to_reader reader_name, book_title

    reader = @readers.find { |r| r.name == reader_name }
    book = @books.find { |b| b.title == book_title}
    reader_with_book = ReaderWithBook.new(book, reader)
    @readers_with_books << reader_with_book
    populate_statistics!
  end
  
  def read_the_book reader_name, duration
    @readers_with_books.find {|r| r.reader.name == reader_name}.read_the_book! duration
    populate_statistics!
  end

  def reader_notification name
    params = reader_notification_params name
    <<-TEXT
    Dear #{params[:reader]}!
    You should return a book "#{params[:book]}" authored by #{params[:author]} in #{params[:hours_untill]} hours.
    Otherwise you will be charged $#{params[:penalty]} per hour.
    By the way, you are on #{params[:current_page]} page now and you need #{params[:time_to_finish]} hours to finish reading "#{params[:book]}"
    TEXT
  end

  def librarian_notification
    params = librarian_notification_params
    <<-TEXT
    Hello, There are #{params[:books_count]} published books in the library.
    There are #{params[:readers_count]} readers and #{params[:readers_with_books]} of them are reading the books.
    #{params[:readers_information]}
    TEXT
  end

  def statistics_notification
    params = statistics_notification_params
    <<-TEXT
    Hello, The library has: #{params[:books_count]} books, #{params[:authors_count]} authors, #{params[:readers_count]} readers
    The most popular author is #{most_pop_author["author_name"]}: #{most_pop_author["pages"]} pages has been read by 4 readers in 2 books.
    The most productive reader is Ivan Testenko: he had read 1040 pages in 3 books authored by 3 authors.
    The most popular book is "The Well-Grounded Rubyist" authored by David A. Black: it had been read for 123.00 hours by 5 readers.
    TEXT
  end

  private

  def reader_notification_params name
    reader_with_book = @readers_with_books.find do |r|
    r.reader.name == name
    end
    {
      reader: reader_with_book.reader.name,
      book: reader_with_book.amazing_book.title,
      author: reader_with_book.amazing_book.author.name,
      hours_untill: (reader_with_book.hours_untill_ret).round(2),
      penalty: (reader_with_book.amazing_book.penalty_per_hour / 100.0).round(2),
      current_page: reader_with_book.current_page,
      time_to_finish: (reader_with_book.time_to_finish).round(2)      
      }
  end

  def librarian_notification_params
    
    inf_readers = ""
    readers_with_books.each do |r|
      inf_readers += (r.reader_name + " is reading \"" + r.book_title + "\" - should return on " + r.return_date.strftime("%F") + " at " + r.return_date.strftime("%r") + " - " + (r.time_to_finish.round(2)).to_s + " hours of reading is needed to finish.\n\n")
    end
    {
      books_count: @books.count,
      readers_count: @readers.count,
      readers_with_books: @readers_with_books.count,
      readers_information: inf_readers
    }

  end

  def statistics_notification_params
    
    {
      books_count: @books.count,
      authors_count: @statistics["authors"].count,
      readers_count: @readers.count
    }
  
  end

  def populate_statistics!
    readers_with_books.each do |r|
      
      @statistics["readers"] ||= {}
      @statistics["readers"][r.reader.name] ||= {"pages" => 0, "books" => 0, "authors" => []}
      @statistics["readers"][r.reader.name]["pages"] += r.current_page
      @statistics["readers"][r.reader.name]["authors"] |= [r.amazing_book.author.name]
      @statistics["readers"][r.reader.name]["books"] += 1
      
      @statistics["book_titles"] ||= {}
      @statistics["book_titles"][r.amazing_book.title] ||= {"author" => "", "reading_hours" => 0, "readers" => []}
      @statistics["book_titles"][r.amazing_book.title]["author"] = r.amazing_book.author.name
      @statistics["book_titles"][r.amazing_book.title]["reading_hours"] += r.reading_hours
      @statistics["book_titles"][r.amazing_book.title]["readers" ] |= [r.reader.name]

      @statistics["authors"] ||= {}
      @statistics["authors"][r.amazing_book.author.name] ||= {"pages" => 0, "books" => 0, "readers" => []}
      @statistics["authors"][r.amazing_book.author.name]["pages"] += r.current_page
      @statistics["authors"][r.amazing_book.author.name]["readers"] |= [r.reader.name]
      @statistics["authors"][r.amazing_book.author.name]["books"] += 1
    end
    @statistics
  end
  
  def statistics_sample
    {
    "readers" => {
      "Ivan Testenko" => {
        "pages" => 1040, 
        "books" => 3, 
        "authors" => ["David A. Black", "Leo Tolstoy", ]
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
        "readers" => 3, 
        "books" => 3
        }
      }
    }
  end

end