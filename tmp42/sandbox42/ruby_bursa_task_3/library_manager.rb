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
    @statistics = {"readers"=>{},"book_titles"=>{},"authors"=>{}}
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

  def reader_notification name
    reader = @readers_with_books.find{|r| r.reader.name == name}
    <<-TEXT
Dear #{name}!

You should return a book \"#{reader.amazing_book.title}\" authored by #{reader.amazing_book.author.name} in #{reader.time_to_read.round} hours.
Otherwise you will be charged $#{reader.amazing_book.penalty_per_hour} per hour.
By the way, you are on #{reader.current_page} page now and you need #{reader.time_to_finish} hours to finish reading #{reader.amazing_book.title}
    TEXT
  end

  def librarian_notification
    a = ""
    @readers_with_books.each {|r| a<<"#{r.reader.name} is reading \"#{r.amazing_book.title}\" - should return on #{r.return_date.strftime("%Y-%m-%d at %I%P")} - #{r.time_to_finish} hours of reading is needed to finish.\n"}
    <<-TEXT 
Hello,

There are #{@books.count} published books in the library.
There are #{@readers.count} readers and #{@readers_with_books.count} of them are reading the books.

#{a}
    TEXT

#Ivan Testenko is reading "War and Peace" - should return on 2015-07-04 at 10am - 5.0 hours of reading is needed to finish.
#Vasiliy Pupkin is reading "Red and Black" - should return on 2015-07-12 at 7pm  - 12.7 hours of reading is needed to finish.
#Barak Obama is reading "The Well-Grounded Rubyist" - should return on 2015-07-10 at 12pm  - 44.5 hours of reading is needed to finish.

  end

  def statistics_notification
    ar = []
    @books.each {|x| ar << [x.author]}
    #puts @statistics
    #puts @statistics["authors"].each_value {|v| v.sort}
    puts @statistics["authors"].each
    most_popular_author
    #puts res[-1]
    #best_author = res[-1]
    #author_name = best_author[1].to_s
    #puts @statistics["authors"].count
<<-TEXT
Hello,

The library has: #{@books.count} books, #{ar.uniq.count} authors, #{@readers.count} readers
The most popular author is #{most_popular_author["author_name"]}: #{most_popular_author["pages"]} pages has been read by #{most_popular_author["readers"].count} readers in #{most_popular_author["books"].count} books.
The most productive reader is #{most_productive_reader["reader_name"]}: he had read #{most_productive_reader["pages"]} pages in #{most_productive_reader["books"]} books authored by #{most_productive_reader["authors"].count} authors.
The most popular book is "#{most_popular_book["book_title"]}" authored by #{most_popular_book["author"]}: it had been read for #{most_popular_book["reading_hours"]} hours by #{most_popular_book["readers"].count} readers.
TEXT
  end

  private

  def reader_notification_params

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
      "author" => "", "reading_hours" => 0, "readers" => []}
      @statistics["book_titles"][r.amazing_book.title]["author"] = r.amazing_book.author.name
      @statistics["book_titles"][r.amazing_book.title]["reading_hours"] += r.reading_hours
      @statistics["book_titles"][r.amazing_book.title]["readers" ] |= [r.reader.name]
      
      @statistics["authors"][r.amazing_book.author.name] ||= {"pages" => 0, "readers" => [], "books" => []}
      @statistics["authors"][r.amazing_book.author.name]["pages"] += r.current_page
      @statistics["authors"][r.amazing_book.author.name]["readers"] |= [r.reader.name]
      @statistics["authors"][r.amazing_book.author.name]["books"] |= [r.amazing_book.title]
    end
    @statistics
  end
  def most_popular_author
    most_popular_author_name = @statistics["authors"].first[0]
    @statistics["authors"].each do |author|
      most_popular_author_name = author[0] if @statistics["authors"][most_popular_author_name]["pages"] < @statistics["authors"][author[0]]["pages"]
    end
    most_popular_author = @statistics["authors"][most_popular_author_name]
    most_popular_author["author_name"] = most_popular_author_name
    most_popular_author
  end
  def most_popular_book
     most_popular_book_title = @statistics["book_titles"].first[0] 
     @statistics["book_titles"].each do |book|
        most_popular_book_title = book[0] if @statistics["book_titles"][most_popular_book_title]["reading_hours"] < @statistics["book_titles"][book[0]]["reading_hours"]
      end
      most_popular_book = @statistics["book_titles"][most_popular_book_title]
      most_popular_book["book_title"] = most_popular_book_title
      most_popular_book
    end
  def most_productive_reader
    most_productive_reader_name = @statistics["readers"].first[0] 
    @statistics["readers"].each do |reader|
      most_productive_reader_name = reader[0] if @statistics["readers"][most_productive_reader_name]["pages"] < @statistics["readers"][reader[0]]["pages"]
    end
    most_productive_reader = @statistics["readers"][most_productive_reader_name]
    most_productive_reader["reader_name"] = most_productive_reader_name
    most_productive_reader
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
