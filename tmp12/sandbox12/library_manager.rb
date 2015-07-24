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

  def find_reader_with_book reader_name
    readers_with_books.find {|r| r.reader.name==reader_name}
  end

  def find_book book_title
  	books.find {|b| b.books.title==book_title}
  end

  def find_reader reader_name
  	readers.find {|r| r.name==reader_name}
  end

  def new_book author, title, price, pages_quantity, published_at
    @books << PublishedBook.new(author, title, price, pages_quantity, published_at)
    populate_statistics!
  end

  def new_reader  name, reading_speed
    @readers << Reader.new(name, reading_speed)
    populate_statistics!
  end

  def give_book_to_reader reader_name, book_title
    @readers_with_books << ReaderWithBook.new(reader_name, book_title)
    populate_statistics!
  end

  def read_the_book reader_name, duration
    ReaderWithBook.find_reader_and_update_current_page(@readers_with_books, reader_name, duration)
    populate_statistics!
  end

  def reader_notification reader_name
    params = reader_notification_params(reader_name)
    <<-TEXT
Dear #{params[:name]}!

You should return a book #{params[:title]} authored by #{params[:author]} in #{params[:time_to_ddl]} hours.
Otherwise you will be charged $#{params[:penalty]} per hour.
By the way, you are on #{params[:page]} page now and you need #{params[:time_to_finish]} hours to finish reading #{params[:title]}
TEXT
  end

  def librarian_notification
  	params = librarian_notification_params
    <<-TEXT
Hello,

There are #{params[:books_number]} published books in the library.
There are #{params[:readers_number]} readers and #{params[:readers_with_books_number]} of them are reading the books.
#{params[:info]}
TEXT
  end

  def statistics_notification
  	params = statistics_notification_params
  	<<-TEXT
Hello,

The library has: #{params[:books_number]} books, #{params[:authors_number]} authors, #{params[:readers_number]} readers
The most popular author is #{params[:best_author]}: #{params[:best_author_pages]} pages has been read in #{params[:best_author_books]} books by #{params[:best_author_readers]} readers.
The most productive reader is #{params[:best_reader]}: he had read #{params[:best_reader_pages]} pages in #{params[:best_reader_books]} books authored by #{params[:best_reader_authors]} authors.
The most popular book is #{params[:best_book]} authored by #{params[:best_book_author]}: it had been read for #{params[:best_book_hours]} hours by #{params[:best_book_readers]} readers.
TEXT
  end

    private

  def most_popular_author
    pages = 0
    auth = {}
    auth_name = ""
    @statistics["authors"].each {|k,h|
    	if h["pages"] > pages
    		pages = h["pages"]
    		auth = h
    		author_name = k
    	end
    }
    {
    	author_name: auth_name,
    	pages_number: pages,
    	books_number: auth["books"].size,
    	readers_number: auth["readers"].size
    }
  end

  def most_productive_reader
  	pages = 0
    reader = {}
    reader_name = ""
    @statistics["readers"].each {|k,h|
    	if h["pages"] > pages
    		pages = h["pages"]
    		reader = h
    		reader_name = k
    	end
    }
    {
    	reader_name: reader_name,
    	pages_number: pages,
    	books_number: reader["books"].size,
    	authors_number: reader["authors"].size
    }  	
  end

  def most_popular_book
  	hours = 0
    book = {}
    title = ""
    @statistics["book_titles"].each { |k,h|
    	if h["reading_hours"] > hours
    		hours = h["reading_hours"]
    		book = h
    		title = k
    	end
    }
    {
    	book_title: title,
    	author: book["author"],
    	reading_hours: hours.round(2),
    	readers: book["readers"].size
    }

  end

  def number_of_authors
  	authors = [] 
  	@books.each {|b| authors << b.author if not authors.include?(b.author)} 
  	authors.size
  end

  def statistics_notification_params
  	the_best_author = most_popular_author
  	the_best_reader = most_productive_reader
  	the_best_book = most_popular_book 
  	{
  	  books_number: books.size, #+ readers_with_books.count),
      readers_number: readers.size,
      authors_number: number_of_authors,
      best_author: the_best_author[:author_name],
      best_reader: the_best_reader[:reader_name],
      best_book: the_best_book[:book_title],
      best_author_pages: the_best_author[:pages_number],
      best_author_books: the_best_author[:books_number],
      best_author_readers: the_best_author[:readers_number],
      best_reader_pages: the_best_reader[:pages_number],
      best_reader_books: the_best_reader[:books_number],
      best_reader_authors: the_best_reader[:authors_number],
      best_book_author: the_best_book[:author],
      best_book_hours: the_best_book[:reading_hours],
      best_book_readers: the_best_book[:reaers]
  	}
  end

  def reader_notification_params reader_name
  	r = find_reader_with_book(reader_name)
  	{
  	  name: r.reader.name,
  	  title: r.amazing_book.title,
  	  author: r.amazing_book.author.name,
  	  time_to_ddl: r.time_to_ddl.round(2),
  	  penalty: (r.amazing_book.penalty_per_hour/100).round(2),
  	  page: r.current_page,
  	  time_to_finish: r.time_to_finish
    }
  end

  def librarian_notification_params
  	str = ""
      readers_with_books.each {|r|
      name = r.reader.name
      title = r.amazing_book.title
      return_date = r.return_date
      time_to_finish = r.time_to_finish
      str += "#{name} is reading #{title} - should return on #{return_date} - #{time_to_finish} hours of reading is needed to finish \n"
    }
    
    {
    	books_number: books.size,
    	readers_number: readers.size,
    	readers_with_books_number: readers_with_books.size,
    	info: str
    }
  end

  def populate_statistics!
 
      @readers_with_books.each do |r|
      @statistics["readers"] = {}
      @statistics["readers"][r.reader.name] ||= {"pages" => 0, "books" => 0, "authors" => []}
      @statistics["readers"][r.reader.name]["pages"] += r.current_page
      @statistics["readers"][r.reader.name]["authors"] |= [r.amazing_book.author.name]
      @statistics["readers"][r.reader.name]["books"] += 1
      
      @statistics["book_titles"] = {}
      @statistics["book_titles"][r.amazing_book.title] ||= {"author" => "", "reading_hours" => 0, "readers" => []}
      @statistics["book_titles"][r.amazing_book.title]["author"] = r.amazing_book.author.name
      @statistics["book_titles"][r.amazing_book.title]["reading_hours"] += r.reading_hours
      @statistics["book_titles"][r.amazing_book.title]["readers"] |= [r.reader.name]
      
      @statistics["authors"] = {}
      @statistics["authors"][r.amazing_book.author] ||= {"pages" => 0, "books" => 0, "readers" => []}
      @statistics["authors"][r.amazing_book.author]["pages"] += r.current_page
      @statistics["authors"][r.amazing_book.author]["readers"] |= [r.reader.name]
      @statistics["authors"][r.amazing_book.author]["books"] += 1
    end
    @statistics
  end
end

 