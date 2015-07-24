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
    @statistics = {}
    populate_statistics!
  end

#LOOK should we check if such book is already exist
  def new_book author, title, price, pages_quantity, published_at
    @books << PublishedBook.new(author, title, price, pages_quantity, published_at)
    @books.last   #for testing in rspec
  end

#LOOK should we check if such reader is already exist
  def new_reader  name, reading_speed
    @readers << Reader.new(name, reading_speed)
    @readers.last   #for testing in rspec
  end

#LOOK should we check if such book is already given
  def give_book_to_reader reader_name, book_title

    reader = @readers.find { |r| r.name == reader_name }
    raise ArgumentError, "No such reader" if readers == nil
    book = @books.find { |b| b.title == book_title }
    raise ArgumentError, "No such book" if book == nil

    @reader_with_books << ReaderWithBook.new(book, reader)
    @reader_with_books.last   #for testing in rspec
  end

  def read_the_book reader_name, duration
    reader = @reader_with_books.find { |r| r.reader.name == reader_name }
    reader.read_the_book! duration
    reader    #for testing in rspec
  end

  def reader_notification reader_name
    rwb = @reader_with_books.find { |r| r.reader.name == reader_name }
<<-TEXT
Dear #{reader_notification_params(rwb)[:reader_name]}!

You should return a book #{reader_notification_params(rwb)[:book_title]} authored by #{reader_notification_params(rwb)[:book_auth_name]} in #{reader_notification_params(rwb)[:time_to_return]} hours.
Otherwise you will be charged $#{reader_notification_params(rwb)[:penalty]} per hour.
By the way, you are on #{reader_notification_params(rwb)[:cur_page]} page now and you need #{reader_notification_params(rwb)[:time_to_fin]} hours to finish reading #{reader_notification_params(rwb)[:book_title]}
TEXT
  end

  def librarian_notification
    @statistics = {}
    populate_statistics!
res = <<-TEXT
Hello,

There are #{statistics_notification_params[:book_count]} published books in the library.
There are #{statistics_notification_params[:reader_count]} readers and #{statistics_notification_params[:active_readers]} of them are reading the books.

TEXT

  @reader_with_books.each { |rwb|
     res << "#{reader_notification_params(rwb)[:reader_name]} "
     res << "is reading #{reader_notification_params(rwb)[:book_title]} "
     res << "- should return on #{librarian_notification_params(rwb)[:return_date]} "
     res << "- #{librarian_notification_params(rwb)[:hours_to_finish]} hours of reading is needed to finish.\n"
  }
  res
  end

  def statistics_notification
    @statistics = {}
    populate_statistics!

    #binding.pry
<<-TEXT
Hello,

The library has: #{statistics_notification_params[:book_count]} books, #{statistics_notification_params[:author_count]} authors, #{statistics_notification_params[:reader_count]} readers
The most popular author is #{statistics_notification_params[:pop_author]}: #{statistics_notification_params[:pop_author_pages]} pages has been read in #{statistics_notification_params[:pop_author_books]} books by #{statistics_notification_params[:pop_author_readers]} readers.
The most productive reader is #{statistics_notification_params[:prod_reader]}: he had read #{statistics_notification_params[:prod_reader_pages]} pages in #{statistics_notification_params[:prod_reader_books]} books authored by #{statistics_notification_params[:prod_reader_auth]} authors.
The most popular book is \"#{statistics_notification_params[:pop_book]}\" authored by #{statistics_notification_params[:pop_book_auth]}: it had been read for #{statistics_notification_params[:pop_book_hours]} hours by #{statistics_notification_params[:pop_book_readers]} readers.
TEXT
  end

  private

  def reader_notification_params rwb
    {
      reader_name: "#{rwb.reader.name}",
      book_title: "\"#{rwb.amazing_book.title}\"",
      book_auth_name: "#{rwb.amazing_book.author.name}",
      time_to_return: "#{ (rwb.hours_overdue*(-1)).round(2) }",
      penalty: "#{ (rwb.amazing_book.penalty_per_hour).round(2)}",
      cur_page: "#{ rwb.current_page }",
      time_to_fin: "#{ rwb.time_to_finish.round(2) }"
    }
  end

  def librarian_notification_params rwb
    {
      return_date: "#{rwb.return_date.strftime("%Y-%m-%d at %-l%P") + (rwb.return_date.hour%12 < 10 ? " " : "")}",
      hours_to_finish: "#{rwb.time_to_finish.round(2)}"
    }

  end

  def the_most_popular_author
  pages_max = 0; auth = {}; name = ""
  @statistics["authors"].each { |k,h| 
    if h["pages"] > pages_max
      pages_max = h["pages"]
      auth = h
      name = k
    end
    }
    {
      name: "#{name}",
      pages: "#{pages_max}",
      book_count: "#{auth["books"]}",
      readers_cnt: "#{auth["readers"].count if auth["readers"] != nil}"
    }
  end

  def the_most_productive_reader
    pages_max = 0; reader = {}; name = ""
    @statistics["readers"].each { |k,h| 
      if h["pages"] > pages_max
        pages_max = h["pages"]
        reader = h
        name = k
      end
     }
     {
      name: "#{name}",
      pages: "#{pages_max}",
      books: "#{reader["books"]}",
      auth: "#{reader["authors"].count if reader["authors"] != nil}"
     }
  end

  def the_most_popular_book
    hours = 0; book = {}; title = ""
    @statistics["book_titles"].each { |k,h| 
      if h["reading_hours"] > hours
        hours = h["reading_hours"]
        book = h
        title = k
      end
     }
     #binding.pry
    {
      title: "#{title}",
      auth: "#{book["author"]}",
      hours: "#{hours.round(2)}",
      readers: "#{book["readers"].count if book["readers"] != nil}"
    }
  end

  def statistics_notification_params
    {
      book_count: "#{@books.count}",
      reader_count: "#{@readers.count}",
      active_readers: "#{@reader_with_books.count }",
      author_count: "#{
        authors = []
        @books.each {|b| authors << b.author if not authors.include?(b.author)}
        authors.count
      }",
      pop_author: "#{the_most_popular_author[:name]}",
      pop_author_pages: "#{the_most_popular_author[:pages]}",
      pop_author_books: "#{the_most_popular_author[:book_count]}",
      pop_author_readers: "#{the_most_popular_author[:readers_cnt]}",
      prod_reader: "#{the_most_productive_reader[:name]}",
      prod_reader_pages: "#{the_most_productive_reader[:pages]}",
      prod_reader_books: "#{the_most_productive_reader[:books]}",
      prod_reader_auth: "#{the_most_productive_reader[:auth]}",
      pop_book: "#{the_most_popular_book[:title]}",
      pop_book_auth: "#{the_most_popular_book[:auth]}",
      pop_book_hours: "#{the_most_popular_book[:hours]}",
      pop_book_readers: "#{the_most_popular_book[:readers]}"
    }
  end

  def populate_statistics!
    @reader_with_books.each do |r|
      @statistics["readers"] ||= {}
      @statistics["readers"][r.reader.name] ||= {"pages" => 0, "books" => 0, "authors" => []}
      @statistics["readers"][r.reader.name]["pages"] += r.current_page
      @statistics["readers"][r.reader.name]["authors"] |= [r.amazing_book.author.name]
      @statistics["readers"][r.reader.name]["books"] += 1
      @statistics["book_titles"] ||= {}
      @statistics["book_titles"][r.amazing_book.title] ||= {
      "author" => "", "reading_hours" => 0, "readers" => []}
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
