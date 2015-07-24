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
    @readers = readers
    @books = books
    @reader_with_books = readers_with_books
    @statistics = {}
    populate_statistics!
  end

  def get_reader_by_name(reader_name)
    readers.find { |reader| reader.name == reader_name }
  end

  def get_reader_with_book_by_name(reader_name)
    readers_with_books.find { |reader| reader.reader.name == reader_name }
  end

  def get_book_by_title(book_title)
    books.find { |book| book.title == book_title }
  end

  def new_book(author, title, price, pages_quantity, published_at)
      books.push(PublishedBook.new(author, title, price, pages_quantity, published_at))
      populate_statistics!
  end

  def new_reader(name, reading_speed)
      readers.push(Reader.new(name, reading_speed))
      populate_statistics!
  end

  def give_book_to_reader(reader_name, book_title)
    bookObj = get_book_by_title(book_title)
    readerObj = get_reader_by_name(reader_name)
    if !bookObj.nil?
      if !readerObj.nil?
        readers_with_books.push(ReaderWithBook.new(bookObj, readerObj))
      else
        puts "Can not find such reader - #{reader_name}"
      end
    else
      puts "Can not find such reader - #{book_title}"
    end
    populate_statistics!
  end

  def read_the_book(reader_name, duration)
      reader = get_reader_with_book_by_name(reader_name)
      reader.read_the_book!(duration)
      populate_statistics!
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

  def reader_notification(name)
      params = reader_notification_params(name)
      <<-TEXT
Dear #{params["name"]}!

You should return a book \"#{params["book"]}\" authored by #{params["author"]} in #{params["hours_to_deadline"]} hours.
Otherwise you will be charged \$#{params["penalty_per_hour"]} per hour.
By the way, you are on #{params["current_page"]} page now and you need #{params["time_to_finish"]} hours to finish reading \"#{params["book"]}\"
      TEXT

   end

  def librarian_notification
      <<-TEXT
Hello,\n
There are #{librarian_notification_params[:number_of_books]} published books in the library.\n
There are #{librarian_notification_params[:number_of_readers]} readers and #{librarian_notification_params[:number_of_readers_with_book]} of them are reading the books.\n
#{librarian_notification_params[:readers_inf]}
      TEXT
  end


  def statistics_notification
 <<-TEXT
Hello,
The library has: #{statistics_notification_params[:quantity_of_books]} books, #{statistics_notification_params[:quantity_of_authors]} authors, #{statistics_notification_params[:quantity_of_readers]} readers
The most popular author is #{most_popular_author['author_name']}: #{most_popular_author["pages"]} pages has been read by #{most_popular_author["readers"].count} readers in #{most_popular_author["books"]} books.
The most productive reader is #{most_productive_reader["reader_name"]}: he had read #{most_productive_reader["pages"]} pages in #{most_productive_reader["books"]} books authored by #{most_productive_reader["authors"].count} authors.
The most popular book is "#{most_popular_book["book_title"]}" authored by #{most_popular_book["author"]}: it had been read for #{most_popular_book["reading_hours"]} hours by #{most_popular_book["readers"].count} readers.
TEXT
  end

  private

  def reader_notification_params(name)
        a = Hash.new
         @reader_with_books.each do |r|
          if r.reader.name == name
            a.store("name", r.reader.name)
            a.store("book", r.amazing_book.title)
            a.store("author", r.amazing_book.author.name)
            a.store("hours_to_deadline", ((r.return_date.to_i - DateTime.now.to_i)/3600.0).round(2))
            a.store("penalty_per_hour", r.amazing_book.penalty_per_hour().round(1)/100)
            a.store("current_page", r.current_page)
            a.store("time_to_finish", reader_with_book.time_to_finish.round(2))
            end
          end
          a
  end

  def librarian_notification_params
      readers_inf = ''
      @reader_with_books.each do |r|
        readers_inf +=(r.reader.name +  " is reading \"" + r.amazing_book.title + "\" - should return on " + r.return_date.strftime("%Y/%m/%d at %I:%M%p").to_s + " - " + r.time_to_finish.round(2).to_s + " hours of reading is needed to finish.")
      end
      { :number_of_books => "#{@books.length}", :number_of_readers => "#{@readers.length}", 
      :number_of_readers_with_book => "#{@reader_with_books.length}",
      :readers_inf => readers_inf}
  end

  def statistics_notification_params
     {quantity_of_books: books.count, quantity_of_authors: @statistics['authors'].count, quantity_of_readers: readers.count}
  end

   def populate_statistics!
      @statistics = statistics_sample
      @reader_with_books.each do |r|
      @statistics['authors'][r.amazing_book.author.name] ||= {'pages' => 0, 'readers' => [], 'books' => 0}
      @statistics['authors'][r.amazing_book.author.name]['pages'] += r.current_page
      @statistics['authors'][r.amazing_book.author.name]['readers'] |= [r.reader.name]
      @statistics['authors'][r.amazing_book.author.name]['books'] += 1
      @statistics['readers'][r.reader.name] ||= {'pages' => 0, 'authors' => [], 'books' => 0}
      @statistics['readers'][r.reader.name]['pages'] += r.current_page
      @statistics['readers'][r.reader.name]['authors'] |= [r.amazing_book.author.name]
      @statistics['readers'][r.reader.name]['books'] += 1
      @statistics['book_titles'][r.amazing_book.title] ||= {'author' => '', 'reading_hours' => 0, 'readers' => []}
      @statistics['book_titles'][r.amazing_book.title]['author'] += r.amazing_book.author.name
      @statistics['book_titles'][r.amazing_book.title]['reading_hours'] += r.reading_hours
      @statistics['book_titles'][r.amazing_book.title]['readers'] |= [r.reader.name]
    end
   end

  def statistics_sample
    {'authors' => {},'readers' => {}, 'book_titles' => {} }
  end

end
