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

  def self.find_reader_and_update_current_page array, name, duration
    #duration кол-во часов успел читатель прочитать
   array.find{|r| r.name  == name }.read_the_book!(duration)
    

  end


  def new_book author, title, price, pages_quantity, published_at

  end

  def new_reader  name, reading_speed

  end

  def give_book_to_reader reader_name, book_title

  end

  def read_the_book reader_name, duration
    ReaderWithBook.find_reader_and_update_current_page(@readers_with_book, reader_name, duration)
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
    <<-TEXT
Hello,

There are #{@@statistics["book_titles"].size} published books in the library.
There are #{@@statistics["readers"].size} readers and #{@@statistics["readers"].size} of them are reading the books.

Ivan Testenko is reading "War and Peace" - should return on 2015-07-04 at 10am - 5.0 hours of reading is needed to finish.
Vasiliy Pupkin is reading "Red and Black" - should return on 2015-07-12 at 7pm  - 12.7 hours of reading is needed to finish.
Barak Obama is reading "The Well-Grounded Rubyist" - should return on 2015-07-10 at 12pm  - 44.5 hours of reading is needed to finish.
    TEXT

  end

  def statistics_notification
    <<-TEXT
Hello,

The library has: 5 books, 4 authors, 6 readers
The most popular author is Leo Tolstoy: 2450 pages has been read in 2 books by 4 readers.
The most productive reader is Ivan Testenko: he had read 1040 pages in 3 books authored by 3 authors.
The most popular book is "The Well-Grounded Rubyist" authored by David A. Black: it had been read for 123.0 hours by 5 readers.
    TEXT
  end

  #private

  def reader_notification_params name
    {
        "name" => @@statistics["notification"][name].to_s,
        "book" => @@statistics["notification"][name]["book"].to_s,
        "author" => @@statistics["notification"][name]["author"].to_s,
        "return_hours" => @@statistics["notification"][name]["return_hours"],
        "penya" =>  @@statistics["notification"][name]["penya"],
        "current_page" => @@statistics["notification"][name]["current_page"],
        "hours_to_finish" => @@statistics["notification"][name]["hours_to_finish"],
        "return_date" => @@statistics["notification"][name]["return_date"]


    }

  end

  def librarian_notification_params

  end

  def statistics_notification_params

  end

  def populate_statistics!



    readers_with_books.each do |r|



      if @@statistics["readers"][r.reader.name] == {}
        @@statistics["readers"][r.reader.name] = {"pages" => 0, "books" => 0, "authors" => []}
      end
      if @@statistics["book_titles"][r.amazing_book.title] == {}
        @@statistics["book_titles"][r.amazing_book.title] = {"author" => " ", "reading_hours" => 0, "readers" => []}

      end

      if  @@statistics["authors"][r.amazing_book.author.name] == {}
        @@statistics["authors"][r.amazing_book.author.name] = {"pages" => 0, "readers" => 0, "books" => 0}
      end

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


      @@statistics["readers"][r.reader.name] ||= {"pages" => 0, "books" => 0, "authors" => []}
      @@statistics["readers"][r.reader.name]["pages"] += r.current_page
      @@statistics["readers"][r.reader.name]["authors"] |= [r.amazing_book.author.name]
      @@statistics["readers"][r.reader.name]["books"] += 1

      @@statistics["book_titles"][r.amazing_book.title] ||= {"author" => " ", "reading_hours" => 0, "readers" => []}
      @@statistics["book_titles"][r.amazing_book.title]["author"] = r.amazing_book.author.name
      @@statistics["book_titles"][r.amazing_book.title]["reading_hours"] += r.reading_hours
      @@statistics["book_titles"][r.amazing_book.title]["readers" ] |= [r.reader.name]

      @@statistics["authors"][r.amazing_book.author.name] ||= {"pages" => 0, "readers" => 0, "books" => 0}
      @@statistics["authors"][r.amazing_book.author.name]["pages"] += r.current_page
      @@statistics["authors"][r.amazing_book.author.name]["readers"] += 1
      @@statistics["authors"][r.amazing_book.author.name]["books"] += 1

      @@statistics["notification"][r.reader.name]["book"] = r.amazing_book.title
      @@statistics["notification"][r.reader.name]["author"] = r.amazing_book.author.name
      @@statistics["notification"][r.reader.name]["return_hours"] = r.hours_overdue
      @@statistics["notification"][r.reader.name]["penya"] = format("%.2f", (r.amazing_book.penalty_per_hour / 100).round(2))
      @@statistics["notification"][r.reader.name]["current_page"] = r.current_page
      @@statistics["notification"][r.reader.name]["hours_to_finish"] = r.time_to_finish
      @@statistics["notification"][r.reader.name]["return_date"] = r.return_date.strftime("%Y-%m-%d at %I%P")

    end


  end


def statistics_sample

  {
      "readers" => {
          "Ivan Testenko" => {
              "pages" => 1040 ,
              "books" => 3,
              "authors" => ["David A. Black", "Leo Tolstoy"]
          }
      },

      "book_titles" => {
          "The Well-Grounded Rubyist" => {
              "author" => "David A. Black" ,
              "reading_hours" => 123.00,
              "readers" => ["Ivan Testenko"]
          }
      },
      "authors" => {
          "Leo Tolstoy" => {
              "pages" => 123 ,
              "readers" => 4,
              "books" => 3
          }
      },
  }

end

  #def test
    #pp @@statistics
    # pp @@statistics["book_titles"].size
 # end



end    #end
=begin
leo_tolstoy = Author.new(1828, 1910, 'Leo Tolstoy')
war_and_peace = PublishedBook.new(leo_tolstoy, 'War and Peace', 1400, 3280, 1996)
anna_karenina = PublishedBook.new(leo_tolstoy, 'Anna Karenina', 1400, 964, 1873)

oscar_wilde = Author.new(1854, 1900, 'Oscar Wilde')
dorian_grey = PublishedBook.new(oscar_wilde, 'The Picture of Dorian Grey', 1400, 208, 1890)

ray_bradbury = Author.new(1920, 2012, 'Ray Bradbury')
fahrenheit451 = PublishedBook.new(ray_bradbury, 'Fahrenheit 451', 1400, 266, 1953)
dandellion_wine = PublishedBook.new(ray_bradbury, 'Dandelion Wine', 1400, 383, 1957)

theodore_dreiser = Author.new(1871, 1945, 'Theodore Dreiser')
the_financier = PublishedBook.new(theodore_dreiser, 'The Financier', 1400, 702, 2014)

ivan = Reader.new('Ivan Testenko', 16)
ivan_testenko = ReaderWithBook.new(war_and_peace, ivan, 333,
                                   Time.now + 36.hours)

nikolay = Reader.new('Nikolay Vasiliev', 20)
vasiliev_nikolay = ReaderWithBook.new(dorian_grey, nikolay, 100,
                                      Time.now + 24.hours)

vasiliy = Reader.new('Vasiliy Pupkin', 15)
vasily_pupkin = ReaderWithBook.new(the_financier, vasiliy, 500)

john = Reader.new('John Smith', 10)

manager = LibraryManager.new([ivan, nikolay, john],

                             [war_and_peace, dorian_grey,
                              fahrenheit451, dandellion_wine,
                              dandellion_wine, dandellion_wine,
anna_karenina, the_financier],

    [ivan_testenko, vasiliev_nikolay, vasily_pupkin])

puts
 #p manager.test
puts

puts 'READER:'
puts manager.reader_notification ivan_testenko.reader.name
puts 'LIBRARIAN:'
puts manager.librarian_notification
puts 'STATISTICS:'
puts manager.statistics_notification
puts '============================='

=end