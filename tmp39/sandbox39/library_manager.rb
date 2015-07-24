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
    book = PublishedBook.new(author, title, price, pages_quantity, published_at)
    
    # Добавление новой книги в статистику.
    statistics_add_book book
    statistics_add_author book.author
 
    @books << book
    book   
  end

  def new_reader  name, reading_speed
    reader = Reader.new(name, reading_speed)
    
    #Добавление нового читателя в статистику.
    statistics_add_reader reader

    @readers << reader
    reader 
  end

  def give_book_to_reader reader_name, book_title
    reader = Reader.find readers, reader_name
    book = PublishedBook.find books, book_title
    return if reader == nil || book == nil

    reader_with_book = ReaderWithBook.new(book, reader)
   
    @readers_with_books << reader_with_book
    
    add_statistics reader_with_book
    
    @readers.delete reader
    @books.delete book

    reader_with_book
  end

  def read_the_book reader_name, duration
    params = ReaderWithBook.find_reader_and_update_current_page(@readers_with_books, reader_name, duration)
    
    reader_with_book = params[0]
    if reader_with_book != nil
      statistics_add_pages reader_with_book, params[1] 
    end
  end

  def reader_notification reader_name
    notification_params = reader_notification_params reader_name 
    return '' if notification_params.length == 0
   
    notification = <<-TEXT
Dear #{reader_name}!
TEXT

    notification_params.each do |params|
      notification << <<-TEXT

You should return a book "#{params[:book_title]}" authored by #{params[:author_name]} in #{sprintf("%.2f", params[:hours_return])} hours.
Otherwise you will be charged $#{sprintf("%.2f", params[:per_hour])} per hour.
By the way, you are on #{params[:current_page]} page now and you need #{sprintf("%.2f", params[:need_hours])} hours to finish reading "#{params[:book_title]}"
TEXT
    end
    notification
  end

  def librarian_notification
    notification_params = librarian_notification_params 
 
    # Хэш с количеством книг.
    notification = ''
    notification_params[0].each do |params|
      notification = <<-TEXT
Hello,

There are #{params[:published_books]} published books in the library.
There are #{params[:readers]} readers and #{params[:readers_reading]} of them are reading the books.

TEXT
      end
    
    #Массив с книгами и читателями.
    notification_params[1].each do |params|
      notification << <<-TEXT
#{params[:reader_name]} is reading "#{params[:book_title]}" - should return on #{params[:return_date]} - #{sprintf("%.2f", params[:need_hours])} hours of reading is needed to finish.
TEXT
    end
    notification
  end

  def statistics_notification
    notification_params = statistics_notification_params 
   
    notification = ''

    notification_params[0].each do |params|
      notification = <<-TEXT
Hello,

The library has: #{params[:books]} books, #{params[:authors]} authors, #{params[:readers]} readers
TEXT
      end

    notification_params[1].each do |params|
    notification << <<-TEXT
The most popular author is #{params[:popular_author]}: #{params[:popular_pages]} pages has been read in #{params[:popular_books]} books by #{params[:popular_readers]} readers.
TEXT
      end

    notification_params[2].each do |params|
    notification << <<-TEXT
The most productive reader is #{params[:productive_reader]}: he had read #{params[:productive_pages]} pages in #{params[:productive_books]} books authored by #{params[:productive_authors]} authors.
TEXT
      end

    notification_params[3].each do |params|
    notification << <<-TEXT
The most popular book is "#{params[:most_popular_book]}" authored by #{params[:most_popular_authored]}: it had been read for #{sprintf("%.2f", params[:most_popular_hours])} hours by #{params[:most_popular_readers]} readers.
TEXT
      end
    notification
  end

  private

  def reader_notification_params reader_name
    params = []
    books = ReaderWithBook.find_reader_with_books readers_with_books, reader_name
    books.each do |reader_with_book|
      need_hours = reader_with_book.time_to_finish.round(2)
      need_hours = need_hours > 0 ? need_hours : 0
      hours_return = reader_with_book.hours_to_return
      hours_return = hours_return > 0 ? hours_return : 0
    
      params << {
                  book_title: reader_with_book.amazing_book.title,
                  author_name: reader_with_book.amazing_book.author.name,
                  hours_return: hours_return,
                  per_hour: reader_with_book.amazing_book.penalty_per_hour.round / 100.0,
                  current_page: reader_with_book.current_page,
                  need_hours: need_hours 
                }
    end
    params
  end

  def librarian_notification_params
    params = []
    params << [{ published_books: @statistics["all_books"].length, 
                 readers: @statistics["all_readers"].length,
                 readers_reading: ReaderWithBook.find_readers(readers_with_books).length }]
    readers = []

    readers_with_books.each do |reader_with_book|
      need_hours = reader_with_book.time_to_finish.round(2)
      need_hours = need_hours > 0 ? need_hours : 0
      readers << {
                  reader_name: reader_with_book.reader.name,
                  book_title: reader_with_book.amazing_book.title,
                  return_date: reader_with_book.return_date.utc.strftime("%Y-%m-%d at ") + 
                                reader_with_book.return_date.utc.strftime("%l%P").strip,
                  need_hours: need_hours
                }
      end
    params << readers
  end

  def statistics_notification_params
    params = []
    params << [{ books: @statistics["all_books"].length, authors: @statistics["all_authors"].length,
                readers: @statistics["all_readers"].length }]

    params << [popular_author_params]
    params << [productive_reader_params]
    params << [popular_book_params]

    params
  end

  def popular_author_params
    params = { popular_author: '', popular_pages: 0,
               popular_books: 0, popular_readers: 0 }
    popular_author = @statistics["authors"].sort{|a, b| a[1]["pages"]<=>b[1]["pages"]}
    
    return params if popular_author.length == 0

    params[:popular_author] = popular_author[-1][0]
    params[:popular_pages] = popular_author[-1][1]["pages"]
    params[:popular_books] = popular_author[-1][1]["books"]
    params[:popular_readers] = popular_author[-1][1]["readers"].length

    params
  end

  def productive_reader_params
    params = { productive_reader: '', productive_pages: 0,
               productive_books: 0, productive_authors: 0 }
    productive_reader = @statistics["readers"].sort{|a, b| a[1]["pages"]<=>b[1]["pages"]}
    
    return params if productive_reader.length == 0

    params[:productive_reader] = productive_reader[-1][0]
    params[:productive_pages] = productive_reader[-1][1]["pages"]
    params[:productive_books] = productive_reader[-1][1]["books"]
    params[:productive_authors] = productive_reader[-1][1]["authors"].length

    params
  end

  def popular_book_params
    params = { most_popular_book: '', most_popular_authored: '',
               most_popular_hours: 0, most_popular_readers: 0}
    productive_reader = @statistics["book_titles"].sort{|a, b| a[1]["reading_hours"]<=>b[1]["reading_hours"]}
    
    return params if productive_reader.length == 0

    params[:most_popular_book] = productive_reader[-1][0]
    params[:most_popular_authored] = productive_reader[-1][1]["author"]
    params[:most_popular_hours] = productive_reader[-1][1]["reading_hours"]
    params[:most_popular_readers] = productive_reader[-1][1]["readers"].length

    params
  end

  def statistics_add_pages r, pages
    @statistics["readers"][r.reader.name]["pages"] += pages
  
    @statistics["authors"][r.amazing_book.author.name]["pages"] += r.current_page

    @statistics["book_titles"][r.amazing_book.title]["reading_hours"] += r.reading_hours pages
  end

  def add_statistics r 
    @statistics["readers"][r.reader.name] ||= {"pages" => 0, "books" => 0, "authors" => []}
    @statistics["readers"][r.reader.name]["pages"] += r.current_page
    @statistics["readers"][r.reader.name]["authors"] |= [r.amazing_book.author.name]
    @statistics["readers"][r.reader.name]["books"] += 1
       
    @statistics["authors"][r.amazing_book.author.name] ||= {"pages" => 0, "readers" => [], "books" => 0}
    @statistics["authors"][r.amazing_book.author.name]["pages"] += r.current_page
    @statistics["authors"][r.amazing_book.author.name]["readers"] |= [r.reader.name]
    @statistics["authors"][r.amazing_book.author.name]["books"] += 1

    @statistics["book_titles"][r.amazing_book.title] ||= {"author" => "", "reading_hours" => 0, "readers" => []}
    @statistics["book_titles"][r.amazing_book.title]["author"] = r.amazing_book.author.name
    @statistics["book_titles"][r.amazing_book.title]["reading_hours"] += r.reading_hours
    @statistics["book_titles"][r.amazing_book.title]["readers"] |= [r.reader.name]
  end

  def populate_statistics!

    @statistics["readers"] = {}
    @statistics["book_titles"] = {}
    @statistics["authors"] = {}
    @statistics["all_readers"] = []
    @statistics["all_books"] = []
    @statistics["all_authors"] = []
    
    readers_with_books.each do |r|
      @statistics["readers"][r.reader.name] ||= {"pages" => 0, "books" => 0, "authors" => []}
      @statistics["readers"][r.reader.name]["pages"] += r.current_page
      @statistics["readers"][r.reader.name]["authors"] |= [r.amazing_book.author.name]
      @statistics["readers"][r.reader.name]["books"] += 1
       
      @statistics["authors"][r.amazing_book.author.name] ||= {"pages" => 0, "readers" => [], "books" => 0}
      @statistics["authors"][r.amazing_book.author.name]["pages"] += r.current_page
      @statistics["authors"][r.amazing_book.author.name]["readers"] |= [r.reader.name]
      @statistics["authors"][r.amazing_book.author.name]["books"] += 1

      @statistics["book_titles"][r.amazing_book.title] ||= {"author" => "", "reading_hours" => 0, "readers" => []}
      @statistics["book_titles"][r.amazing_book.title]["author"] = r.amazing_book.author.name
      @statistics["book_titles"][r.amazing_book.title]["reading_hours"] += r.reading_hours
      @statistics["book_titles"][r.amazing_book.title]["readers"] |= [r.reader.name]
      
      statistics_add_book r.amazing_book
      statistics_add_reader r.reader
      statistics_add_author r.amazing_book.author
     end

    books.each do |book|
      statistics_add_book book      
      statistics_add_author book.author  
    end
    
    readers.each do |reader|
      statistics_add_reader reader      
    end
      
    @statistics
  end

  def statistics_add_book book
    @statistics["all_books"] |= [book.title]
  end
  
  def statistics_add_reader reader
    @statistics["all_readers"] |= [reader.name]
  end
  
  def statistics_add_author author
    @statistics["all_authors"] |= [author.name]
  end
 
end