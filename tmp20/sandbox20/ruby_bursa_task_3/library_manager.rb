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
    @reader_with_books = readers_with_books
    @readers = readers
    @books = books
    @statistic = {}
    populate_statistics!
  end

  def new_book author, title, price, pages_quantity, published_at
    book = PublishedBook.new(author, title, price, pages_quantity, published_at)
    @books << book
    book
  end

  def new_reader  name, reading_speed
    reader = Reader.new(name, reading_speed)
    @readers << reader
    reader
  end

  def give_book_to_reader reader_name, book_title, return_date = (Time.now + 2.weeks)

    reader = @readers.find { |r| r.name == reader_name }
    book = @books.find { |b| b.title == book_title}
    reader_with_book = ReaderWithBook.new(book, reader, return_date)
    @readers_with_books << reader_with_book
    reader_with_book
  end
  
  def read_the_book reader_name, duration
    ReaderWithBook.find_reader_and_update_current_page(@readers_with_books, reader_name, duration)

  end

  def reader_notification name
    params = reader_notification_params name
    <<-TEXT
    Dear #{params[:reader]}!
    You should return a book "#{params[:book]}" authored by #{params[:author]} in #{params[:hours_to_deadline]} hours.
    Otherwise you will be charged $#{params[:penalty]} per hour.
    By the way, you are on #{params[:current_page]} page now and you need #{params[:time_to_finish]} hours to finish reading "#{params[:book]}"
    TEXT
  end

  def librarian_notification
    params = librarian_notification_params
    <<-TEXT
    Hello, There are #{params[:books_count]} published books in the library.
    There are #{params[:readers_count]} readers and #{params[:readers_with_books]} of them are reading the books.
    #{params[:reader]} is reading "#{params[:book]}" - should return on #{[return_d:]} - #{[return_hour:]} hours of reading is needed to finish.
    Vasiliy Pupkin is reading "Red and Black" - should return on 2015-07-12 at 7pm  - 12.75 hours of reading is needed to finish.
    Barak Obama is reading "The Well-Grounded Rubyist" - should return on 2015-07-10 at 12pm  - 44.50 hours of reading is needed to finish.
    TEXT
  end

  def statistics_notification
    params = statistics_notification_params
    <<-TEXT
    Hello, The library has: 5 books,  4 authors, 6 readers
    The most popular author is Leo Tolstoy: 2450 pages has been read by 4 readers in 2 books.
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
      book: reader_with_book.book.title,
      author: reader_with_book.book.author.name,
      hours_to_deadline: reader_with_book.hours_to_deadline.round,
      penalty: (reader_with_book.book.penalty_per_hour / 100.0).round(2),
      current_page: reader_with_book.current_page,
      time_to_finish: reader_with_book.time_to_finish       
      }
  end

  def librarian_notification_params
    {
      books_count: @books.count,
      readers_count: @readers.count,
      readers_with_books: @readers_with_books.count 
      reader: reader_with_book.reader.name,
      book: reader_with_book.book.title,
      return_d: reader_with_book.return_date.strftime("%Y-%m-%d"),
      return_hour: reader_with_book.return_date.strftime("%l%P")
    }

  end

  def statistics_notification_params
    {}
  
  end

  def populate_statistics!
    readers_with_books.each do |r|
      @statistic["readers"][r.reader.name] |= {"pages" => 1040, "books" => 3, "authors" => 3 } 
      @statistic["readers"][r.reader.name]["pages"] += r.current_page
      @statistic["readers"][r.reader.name]["authors"] |= [r.amazing_book.author.name] 
      @statistic["readers"][r.reader.name]["books"] += 1

      @statistic["book_titles"][r.amazing_book.title] ||= {"author" => "", "reading_hours" => 0, "readers" => [] } 
      @statistic["book_titles"][r.amazing_book.title]["author"] += r.amazing_book.author.name
      @statistic["book_titles"][r.amazing_book.title]["reading_hours"] += r.reading_hours
      @statistic["book_titles"][r.amazing_book.title]["readers"] |= [r.reader.name]
  end
  
  def statistics_sample
     @statistic
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