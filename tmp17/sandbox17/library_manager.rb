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

  def new_book author, title, price, pages_quantity, published_at
    @books << PublishedBook.new(author, title, price, pages_quantity,
                                published_at)
    @books[-1]
  end

  def new_reader  name, reading_speed
        @readers << Reader.new(name, reading_speed)
        @readers[-1]
  end

  def give_book_to_reader reader_name, book_title
     this_reader = readers.find {|reader| reader.name == reader_name }
     this_book = readers_with_books.find { |book| book.title == book_title }
     if this_reader
       if this_book
         readers_with_books << ReaderWithBook.new(this_book, this_reader)
       else
         puts "no such book:" + book_title
      end
      else
        puts "no such reader:" + reader_name
      end
  end

  def read_the_book reader_name, duration
    this_reader = readers.find {|reader| reader.name == reader_name }
    this_reader.read_the_book!(duration)
  end
  def reader_notification reader_name
    p = reader_notification_params(reader_name)
    return <<-TEXT
Dear #{p[:reader_name]}!
You should return a book "#{p[:book_title]}" authored by #{p[:author_name]} in #{p[:hours_until_return]} hours.
Otherwise you will be charged $#{p[:penalty_per_hour]} per hour.
By the way, you are on #{p[:current_page]} page now and you need #{p[:hours_to_finish]} hours to finish reading "#{p[:book_title]}"
TEXT
  end

  def librarian_notification
    p = librarian_notification_params
    return <<-TEXT
Hello,
There are #{p[:books_count]} published books in the library.
There are #{p[:readers_count]} readers and #{p[:readers_w_b_count]} of them are reading the books.
#{p[:readers_w_b_info]}
TEXT
  end

  def statistics_notification
    p = statistics_notification_params
    return <<-TEXT
Hello,
The library has: #{p[:books]} books, #{p[:authors]} authors, #{p[:readers]} readers
TEXT
  end
  private

    def reader_notification_params reader_name
      r = @readers_with_books.find { |reader_w_b| reader_w_b.reader.name == reader_name }
      p = {}
      p[:reader_name] = r.reader.name
      p[:book_title] = r.amazing_book.title
      p[:author_name] = r.amazing_book.author.name
      p[:hours_until_return] = format('%.2f', r.hours_until_return.round(2))
      p[:penalty_per_hour] = format('%.2f', r.amazing_book.penalty_per_hour.round(2))
      p[:current_page] = r.current_page
      p[:hours_to_finish] = format('%.2f', r.hours_to_finish.round(2))
      return p
    end

        def librarian_notification_params
          p = {}
          p[:books_count] = @books.size
          p[:readers_count] = @readers.size
          p[:readers_w_b_count] = @readers_with_books.size
          # p[:readers_w_b_info] = @readers_with_books.inject("") { |memo, reader_w_b| memo + reader_w_b.inspect + "\n" }
          p[:readers_w_b_info] = @readers_with_books.map do |reader_w_b|
            "#{reader_w_b.reader.name} is reading \"#{reader_w_b.amazing_book.title}\"" +
            " - should return on #{reader_w_b.return_date.strftime("%F")} at#{' ' + reader_w_b.return_date.strftime("%l%p").downcase.strip}" +
            " - #{format('%.2f', reader_w_b.hours_to_finish.round(2))} hours of reading is needed to finish."
          end.join("\n")
          return p
        end

        def statistics_notification_params
          p = {}
          p[:books] = @books.size
          p[:authors] = @books.map { |b| b.author}.uniq.size
          p[:readers] = @readers.size
          # p_authors = {}
          # @readers_with_books.each do |reader_w_b|
          #   p_authors[reader_w_b.amazing_book.author.name] +=
          # end
          return p
        end

        def populate_statistics!

        end

    end
