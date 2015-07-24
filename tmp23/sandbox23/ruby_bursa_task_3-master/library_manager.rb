require 'active_support/all'
require 'pry'
require 'byebug'

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
    # populate_statistics!
  end

  def new_book author, title, price, pages_quantity, published_at
    books << PublishedBook.new(author, title, price, pages_quantity, published_at)
  end


  def new_reader  name, reading_speed
    readers << Reader.new(name, reading_speed)
  end

  def give_book_to_reader reader_name, book_title
    reader = find_reader(reader_name)
    book = find_book(book_title)
    readers_with_books << reader
    readers.delete(reader) 
  end

  def read_the_book reader_name, duration
    ReaderWithBook.find_reader_and_update_current_page(@readers_with_books, reader_name, duration)
  end


  def reader_notification name
  end

  def librarian_notification
  end

  def statistics_notification
  end


  private

  def find_reader(reader_name)
    # byebug
    readers.each do |reader|
      # byebug
      return reader if (reader.name == reader_name)
    end
    nil
  end

  def find_book(book_title)
    books.each do |book|
      return book if (book.title == book_title)
    end
    nil
  end

  def find_reader_with_book(reader_name)
    readers_with_books.each do |reader_with_book|
      # byebug
      return reader_with_book if (reader_with_book.reader.name == reader_name)
    end
    nil
  end    

  def reader_notification_params(reader_name)
    reader_with_book = find_reader_with_book(reader_name)
    puts reader_with_book.inspect
    # byebug
    params_reader_with_book = {
      'name' => reader_with_book.reader.name,
      'title' => reader_with_book.amazing_book.title
    }
    # byebug    
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
