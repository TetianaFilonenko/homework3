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
    books.push(PublishedBook.new author, title, price, pages_quantity, published_at)
    books.last
  end

  def new_reader  name, reading_speed
    readers.push(Reader.new name, reading_speed)
    readers.last
  end

  def give_book_to_reader reader_name, book_title
    reader = readers.find{|r| r.name == reader_name}
    book = books.find{|b| b.title == book_title}
    readers_with_books.push(ReaderWithBook.new book, reader)
    readers_with_books.last
  end

  def read_the_book reader_name, duration
    reader_with_book = readers_with_books.find{|r| r.reader.name == reader_name}
    reader_with_book.read_the_book! duration
    reader_with_book
  end

  def reader_notification reader_name
    reader_with_book = readers_with_books.find{|r| r.reader.name == reader_name}
    rnParams = reader_notification_params reader_with_book
<<-TEXT
Dear #{reader_name}!

You should return a book "#{rnParams[:book_title]}" authored by #{rnParams[:book_author]} in #{rnParams[:hours_to_deadline]} hours.
Otherwise you will be charged $#{rnParams[:penalty]} per hour.
By the way, you are on #{rnParams[:curr_page]} page now and you need #{rnParams[:time_to_finish]} hours to finish reading "#{rnParams[:book_title]}"
TEXT
  end

  def librarian_notification
    lnParams = librarian_notification_params
res = <<-TEXT
Hello,

There are #{lnParams[:books_count]} published books in the library.
There are #{lnParams[:readers_count]} readers and #{lnParams[:readers_with_books_count]} of them are reading the books.

TEXT
    readers_with_books.each {|rwb| 
      rnParams = reader_notification_params rwb
      res << "#{rwb.reader.name} is reading \"#{rnParams[:book_title]}\" - should return on #{rwb.return_date.strftime("%Y-%m-%d at %-l%P")} - #{rnParams[:time_to_finish]} hours of reading is needed to finish.\n"
    }
    res
  end

  def statistics_notification
    lnParams = librarian_notification_params
    snParams = statistics_notification_params
<<-TEXT
Hello,

The library has: #{lnParams[:books_count]} books, #{lnParams[:authors_count]} authors, #{lnParams[:readers_count]} readers
The most popular author is #{snParams[:the_most_popular_author][:name]}: #{snParams[:the_most_popular_author][:pages]} pages has been read in #{snParams[:the_most_popular_author][:books]} books by #{snParams[:the_most_popular_author][:readers]} readers.
The most productive reader is #{snParams[:the_most_productive_reader][:name]}: he had read #{snParams[:the_most_productive_reader][:pages]} pages in #{snParams[:the_most_productive_reader][:books]} books authored by #{snParams[:the_most_productive_reader][:authors]} authors.
The most popular book is "#{snParams[:the_most_popular_book][:title]}" authored by #{snParams[:the_most_popular_book][:author]}: it had been read for #{snParams[:the_most_popular_book][:reading_hours]} hours by #{snParams[:the_most_popular_book][:readers]} readers.
TEXT

  end

  private

  def reader_notification_params reader_with_book
    {
      penalty:  format('%.2f', (reader_with_book.amazing_book.penalty_per_hour / 100.0).round(2)),
      hours_to_deadline: reader_with_book.return_date > Time.now.utc ? ((reader_with_book.return_date.to_i - Time.now.utc.to_i) / 3600.0).round(2) : 0,
      book_title: reader_with_book.amazing_book.title,
      book_author: reader_with_book.amazing_book.author.name,
      curr_page: reader_with_book.current_page,
      time_to_finish:reader_with_book.time_to_finish.round(2)
    }
  end

  def librarian_notification_params
    {
      books_count: books.count,
      readers_count: readers.count,
      readers_with_books_count: readers_with_books.count,
      authors_count: authors_count
    }
  end

  def authors_count
    a = []
    books.each{|b| a << b.author}
    a.uniq.count
  end

  def statistics_notification_params
    {
      the_most_popular_author: the_most_popular_author,
      the_most_productive_reader: the_most_productive_reader,
      the_most_popular_book: the_most_popular_book
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

  def the_most_popular_author
    sort_arr = @statistics["authors"].sort_by {|k,v| v["pages"]}.reverse[0]
    {
      name: sort_arr[0],
      pages: sort_arr[1]["pages"],
      books: sort_arr[1]["books"],
      readers: sort_arr[1]["readers"] != nil ? sort_arr[1]["readers"].count : 0
    }
  end

  def the_most_productive_reader
    sort_arr = @statistics["readers"].sort_by {|k,v| v["pages"]}.reverse[0]
    {
      name: sort_arr[0],
      pages: sort_arr[1]["pages"],
      books: sort_arr[1]["books"],
      authors: sort_arr[1]["authors"] != nil ? sort_arr[1]["authors"].count : 0
    }
  end

  def the_most_popular_book
    sort_arr = @statistics["book_titles"].sort_by {|k,v| v["reading_hours"]}.reverse[0]
    {
      title: sort_arr[0],
      author: sort_arr[1]["author"],
      reading_hours: sort_arr[1]["reading_hours"],
      readers: sort_arr[1]["readers"] != nil ? sort_arr[1]["readers"].count : 0
    }
  end
end
