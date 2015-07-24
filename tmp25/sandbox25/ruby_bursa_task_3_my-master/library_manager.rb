require 'active_support/all'
require 'pry'

require_relative 'author.rb'
require_relative 'book.rb'
require_relative 'published_book.rb'
require_relative 'reader.rb'
require_relative 'reader_with_book.rb'

# User have to have only one book at one moment
class LibraryManager
  attr_accessor :readers, :books, :readers_with_books, :authors

  def initialize(readers = [], books = [], readers_with_books = [], authors = [])
    @readers_with_books = readers_with_books
    @readers = readers
    @books = books
    @authors = authors
  end

  def new_author year_of_birth, year_of_death, name
    author = Author.new(year_of_birth, year_of_death, name)
    @authors << author
    author
  end

  def new_book(author, title, price, pages_quantity, published_at)
    book = PublishedBook.new(author, title, price, pages_quantity, published_at)
    @books << book
    book
  end

  def new_reader(name, reading_speed)
    reader = Reader.new(name, reading_speed)
    @readers << reader
    reader
  end

  def give_book_to_reader(reader_name, book_title, return_date = (Time.now + 2.weeks))
    reader = @readers.find { |r| r.name == reader_name }
    book = @books.find { |b| b.title == book_title}
    if !book.reader.nil? 
      @readers_with_books.delete_if { |r| r.book.title == book_title }
      book.reader = nil
    end
    reader_with_book = ReaderWithBook.new(book, reader, return_date)
    @readers_with_books << reader_with_book
    reader_with_book
  end

  def read_the_book(reader_name, duration)
#   ReaderWithBook.find_reader_and_update_current_page(@readers_with_books, reader_name, duration)    
    @readers_with_books.find {|r| r.reader.name == reader_name}.read_the_book!(duration)
  end

  def reader_notification(reader_name)
    params =  reader_notification_params reader_name
    <<-TEXT
Dear #{params[:reader]}!

You should return a book "#{params[:book]}" authored by #{params[:author]} in #{params[:hours_to_deadline]} hours.
Otherwise you will be charged $#{params[:penalty]} per hour.
By the way, you are on #{params[:current_page]} page now and you need #{params[:time_to_finish]} hours to finish reading "#{params[:book]}"
    TEXT
  end

  def librarian_notification
    params =  librarian_notification_params
    str = ""
    @readers_with_books.each do |r|    
    str << %Q{#{r.reader.name} is reading "#{r.book.title}" - should return on #{r.return_date.strftime("%Y-%m-%d")} at #{r.return_date.strftime("%l%P")} - #{r.hours_to_deadline.round(1)} hours of reading is needed to finish.
}
    end
    <<-TEXT
Hello,

There are #{params[:books_count]} published books in the library.
There are #{params[:readers_count]} readers and #{params[:readers_with_books]} of them are reading the books.

#{str}
    TEXT
  end

  def statistics_notification
    params = statistics_notification_params
  <<-TEXT
Hello,

The library has: #{params[:books_count]} books, #{params[:authors_count]} authors, #{params[:readers_count]} readers
The most popular author is #{params[:pop_auth]}: #{params[:pop_auth_pages]} pages has been read in #{params[:pop_auth_books]} books by #{params[:pop_authreaders]} readers.
The most productive reader is Ivan Testenko: he had read 1040 pages in 3 books authored by 3 authors.
The most popular book is "The Well-Grounded Rubyist" authored by David A. Black: it had been read for 123.0 hours by 5 readers.
  TEXT
  end

  private

  def reader_notification_params(reader_name)
    reader_with_book = @readers_with_books.find do |r|
      r.reader.name == reader_name
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
    }
  end

  def statistics_notification_params
   author = popular_author 
    {
      books_count: @books.count,
      authors_count: @authors.count,
      readers_count: @readers.count,
      pop_auth: author.keys[0],
      pop_auth_pages: author.values[0][:pages],
      pop_auth_books: author.values[0][:books],
      pop_auth_readers: author.values[0][:readers]
    }
  end

  def popular_author
    auths = {}
    
    @authors.each do |a|      
      pages = 0
      times = 0
      readers = []
      books = 0 
      a.books.each do |b|
        b.readed_info.each_value do |v|
          pages += v[:pages]
          times += v[:times]
        end        
        b.readed_info.keys.each {|v| readers << v}        
        books += 1 if !b.readed_info.empty?
      end
      readers.uniq!
      auths.merge!({a.name =>{:pages => pages, :books => books, :readers =>readers.count}})  
    end

    max = 0
    max_auth = ""

    auths.each do |k, v|
      if max < v[:pages]
        max = v[:pages]
        max_auth = k        
      end  
    end

    { max_auth => auths[max_auth] }
  end

end
