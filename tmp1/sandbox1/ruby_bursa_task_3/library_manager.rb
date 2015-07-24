require 'active_support/all'
require 'pry'

require_relative 'author.rb'
require_relative 'book.rb'
require_relative 'published_book.rb'
require_relative 'reader.rb'
require_relative 'reader_with_book.rb'

class LibraryManager

  @@statistics = Hash.new { |h, k| h[k]=Hash.new(&h.default_proc) }

  attr_accessor :readers, :books, :readers_with_books

  def initialize readers = [], books = [], readers_with_books = []
    @readers_with_books = readers_with_books
    @readers = readers
    @books = books.uniq

    populate_statistics!

  end

  def new_book author, title, price, pages_quantity, published_at

  end

  def new_reader name, reading_speed
    @@statistics["readers"][name] = {"pages" => 0, "books" => 0, "authors" => []}


  end


  def give_book_to_reader reader_name, book_title

  end

  def read_the_book reader_name, duration
    ReaderWithBook.find_reader_and_update_current_page(@readers_with_books, reader_name, duration)
  end

  def reader_notification name
    params = reader_notification_params name


    <<-TEXT
Dear #{name}!

You should return a book "#{params["book"]}" authored by #{params["author"]} in #{params["return_hours"]} hours.
Otherwise you will be charged $#{params["penya"]} per hour.
By the way, you are on #{params["current_page"]} page now and you need #{params["hours_to_finish"]} hours to finish reading "#{params["book"]}"
    TEXT


  end

  def librarian_notification

    params = librarian_notification_params

    <<-TEXT
Hello,

There are #{params["books"]} published books in the library.
There are #{params["readers"]} readers and #{params["readers_wb"]} of them are reading the books.

#{params["stat"]}

    TEXT

  end

  def statistics_notification
    params = statistics_notification_params
    <<-TEXT
Hello,

The library has: #{params["all_books"]} books, #{params["all_authors"]} authors, #{params["all_readers"]} readers
#{params["best_author"]}
    #{params["best_reader"]}
    #{params["best_book"]}
    TEXT

  end

  def test
    pp @@statistics
  end

  private

  def reader_notification_params name
    {
        "name" => @@statistics['notification'][name].to_s,
        "book" => @@statistics['notification'][name]["book"].to_s,
        "author" => @@statistics['notification'][name]["author"].to_s,
        "return_hours" => @@statistics['notification'][name]["return_hours"],
        "penya" => @@statistics['notification'][name]["penya"],
        "current_page" => @@statistics['notification'][name]["current_page"],
        "hours_to_finish" => @@statistics['notification'][name]["hours_to_finish"]
    }

  end

  def librarian_notification_params


    {

        "books" => @@statistics["all_stat"]["all_book"],
        "readers" => @@statistics["all_stat"]["all_readers"],
        "readers_wb" => @@statistics["all_stat"]["all_readers_with_book"],
        "stat" => "#{
        z = ""
        @@statistics['notification'].each do |x|

          z += "#{x[0]}  is reading  #{x[1]["book"]} - should return on  #{x[1]["return_date"]} - #{format("%.2f", (x[1]["hours_to_finish"]).round(2))} hours of reading is needed to finish. \n".to_s

        end
        z.chomp
        }"

    }

  end

  def statistics_notification_params

    author = @@statistics["authors"].sort_by { |x, y| y["pages"] }.reverse.to_h.first
    reader = @@statistics["readers"].sort_by { |x, y| y["pages"] }.reverse.to_h.first
    book = @@statistics["book_titles"].sort_by { |x, y| y["reading_hours"] }.reverse.to_h.first

    {
        "all_books" => @@statistics["all_stat"]["all_book"],
        "all_authors" => @@statistics["all_stat"]["all_authors"],
        "all_readers" => @@statistics["all_stat"]["all_readers"],
        "best_author" => "The most popular author is #{author[0]}: #{@@statistics["authors"][author[0]]["pages"]} pages has been read in #{@@statistics["authors"][author[0]]["books"]} books by #{@@statistics["authors"][author[0]]["readers"]} readers.",
        "best_reader" => "The most productive reader is #{reader[0]}: he had read #{@@statistics["readers"][reader[0]]["pages"]} pages in #{@@statistics["readers"][reader[0]]["books"]} books authored by #{@@statistics["readers"][reader[0]]["authors"].size} authors.",
        "best_book" => "The most popular book is " + '"'+ book[0] + '"' + " authored by " + @@statistics["book_titles"][book[0]]["author"][0] + ": it had been read for #{@@statistics["book_titles"][book[0]]["reading_hours"]} hours by #{@@statistics["book_titles"][book[0]]["readers"].size} readers."
    }

  end


  def populate_statistics!
    if @@statistics["all_stat"] == {}
      @@statistics["all_stat"] = {
          "all_book" => 0,
          "all_authors" => 0,
          "all_readers" => 0,
          "all_readers_with_book" => 0,
      }
    end

    readers.each do |r|

      if @@statistics["readers"][r.name] == {}
        @@statistics["readers"][r.name] = {"pages" => 0, "books" => 0, "authors" => []}

      end

    end


    books.each do |r|

      if @@statistics["book_titles"][r.title] == {}
        @@statistics["book_titles"][r.title] = {
            "author" => [], "reading_hours" => 0, "readers" => []}

      end
      if @@statistics["authors"][r.author.name] == {}
        @@statistics["authors"][r.author.name] = {"pages" => 0, "readers" => 0, "books" => 0}

      end
      @@statistics["authors"][r.author.name]["books"] += 1
      @@statistics["book_titles"][r.title]["author"] |= [r.author.name]


    end


    readers_with_books.each do |r|


      if @@statistics["readers"][r.reader.name] == {}
        @@statistics["readers"][r.reader.name] = {"pages" => 0, "books" => 0, "authors" => []}

      end

      @@statistics["readers"][r.reader.name]["pages"] += r.current_page
      @@statistics["readers"][r.reader.name]["authors"] |= [r.amazing_book.author.name]
      @@statistics["readers"][r.reader.name]["books"] += 1

      if @@statistics["book_titles"][r.amazing_book.title] == {}
        @@statistics["book_titles"][r.amazing_book.title] = {
            "author" => [], "reading_hours" => 0, "readers" => []}
      end

      @@statistics["book_titles"][r.amazing_book.title]["author"] |= [r.amazing_book.author.name]
      @@statistics["book_titles"][r.amazing_book.title]["reading_hours"] += r.reading_hours
      @@statistics["book_titles"][r.amazing_book.title]["readers"] |= [r.reader.name]


      if @@statistics["authors"][r.amazing_book.author.name] == {}
        @@statistics["authors"][r.amazing_book.author.name] = {"pages" => 0, "readers" => 0, "books" => 0}

      end
      @@statistics["authors"][r.amazing_book.author.name]["pages"] += r.current_page


      @@statistics["authors"][r.amazing_book.author.name]["readers"] += 1
      @@statistics["authors"][r.amazing_book.author.name]["books"] += 1


      if @@statistics["notification"][r.reader.name] == {}
        @@statistics["notification"][r.reader.name] = {
            "book" => "",
            "author" => "",
            "return_hours" => 0.0,
            "penya" => 0,
            "current_page" => 0,
            "hours_to_finish" => 0.00,
            "return_date" => ""
        }
      end

      @@statistics["notification"][r.reader.name]["book"] = r.amazing_book.title
      @@statistics["notification"][r.reader.name]["author"] = r.amazing_book.author.name
      @@statistics["notification"][r.reader.name]["return_hours"] = r.hours_overdue
      @@statistics["notification"][r.reader.name]["penya"] = format("%.2f", (r.amazing_book.penalty_per_hour / 100).round(2))
      @@statistics["notification"][r.reader.name]["current_page"] = r.current_page
      @@statistics["notification"][r.reader.name]["hours_to_finish"] = r.time_to_finish
      @@statistics["notification"][r.reader.name]["return_date"] = r.return_date.strftime("%Y-%m-%d at %I%P")


    end
    authors = Array.new
    books.uniq.each do |x|
      authors |= [x.author.name]
    end
    @@statistics["all_stat"]["all_book"] = books.size
    @@statistics["all_stat"]["all_readers"] = @@statistics["readers"].size
    @@statistics["all_stat"]["all_readers_with_book"] = readers_with_books.size
    @@statistics["all_stat"]["all_authors"] = authors.size


    @@statistics
  end


end

