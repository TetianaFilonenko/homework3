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
    # binding.pry
    @readers = (readers_with_books.map { |r_w_b| r_w_b.reader} + readers).uniq
    @books = (readers_with_books.map { |r_w_b| r_w_b.amazing_book} + books).uniq
    @readers_with_books = readers_with_books
    @statistics = {:authors => {}, :readers => {}, :books => {}}
    init_statistics!
    # binding.pry
  end

  def new_book! author, title, price, pages_quantity, published_at
    books.push(PublishedBook.new(author, title, price, pages_quantity, published_at))
  end

  def new_reader! reader_name, reading_speed
    readers.push(Reader.new(reader_name, reading_speed))
  end

  def give_book_to_reader! reader_name, book_title
    @readers_with_books.push(ReaderWithBook.new(@books.find { |book| book.title == book_title},
      @readers.find { |reader| reader.name == reader_name }))
  end

  def read_the_book! reader_name, duration
    i = @readers_with_books.index { |reader_w_b| reader_w_b.reader.name = reader_name}
    @readers_with_books[i].current_page += (@readers_with_books[i].reader.reading_speed * duration.to_f).floor
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
The most popular author is #{p[:author]}: #{p[:author_p]} pages has been read in #{p[:author_b]} books by #{p[:author_r]} readers.
The most productive reader is #{p[:reader]}: he had read #{p[:reader_p]} pages in #{p[:reader_b]} books authored by #{p[:reader_a]} authors.
The most popular book is "#{p[:book]}" authored by #{p[:book_a]}: it had been read for #{p[:book_h]} hours by #{p[:book_r]} readers.
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

      p_author = @statistics[:authors].max_by { |x| x[1][:p] }
      p[:author] = p_author[0]
      p[:author_p] = p_author[1][:p]
      p[:author_b] = p_author[1][:b].size
      p[:author_r] = p_author[1][:r].size

      p_reader = @statistics[:readers].max_by { |x| x[1][:p] }
      p[:reader] = p_reader[0]
      p[:reader_p] = p_reader[1][:p]
      p[:reader_b] = p_reader[1][:b].size
      p[:reader_r] = p_reader[1][:a].size
      
      p_book = @statistics[:books].max_by { |x| x[1][:h] }
      p[:book] = p_book[0]
      p[:book_a] = p_book[1][:a]
      p[:book_h] = format('%.2f', p_book[1][:h].round(2))
      p[:book_r] = p_book[1][:r].size
      return p
    end

    def init_statistics!
      readers_with_books.each do |r_w_b|
        # init authors stats
        stat_author_add_pages!(r_w_b.amazing_book.author.name,
          r_w_b.current_page,
          r_w_b.amazing_book.title,
          r_w_b.reader.name)
        # init readers stats
        stat_reader_add_pages!(r_w_b.reader.name,
          r_w_b.current_page,
          r_w_b.amazing_book.title,
          r_w_b.amazing_book.author.name)
        # init books stats
        stat_book_add_pages!(r_w_b.amazing_book.title,
          r_w_b.amazing_book.author.name,
          r_w_b.current_page / r_w_b.reader.reading_speed.to_f,
          r_w_b.reader.name)
      end
    end

    def stat_author_add_pages! author_name, pages, book_title, reader_name
      unless @statistics[:authors].has_key? author_name then
        @statistics[:authors][author_name] = {:p => 0, :b => [], :r => []}
      end
      @statistics[:authors][author_name][:p] += pages
      @statistics[:authors][author_name][:b].push(book_title)
      @statistics[:authors][author_name][:b].uniq!
      @statistics[:authors][author_name][:r].push(reader_name)
      @statistics[:authors][author_name][:r].uniq!
    end

    def stat_reader_add_pages! reader_name, pages, book_title, author_name
      unless @statistics[:readers].has_key? reader_name then
        @statistics[:readers][reader_name] = {:p => 0, :b => [], :a => []}
      end
      @statistics[:readers][reader_name][:p] += pages
      @statistics[:readers][reader_name][:b].push(book_title)
      @statistics[:readers][reader_name][:b].uniq!
      @statistics[:readers][reader_name][:a].push(author_name)
      @statistics[:readers][reader_name][:a].uniq!
    end

    def stat_book_add_pages! book_title, author_name, hours, reader_name
      unless @statistics[:books].has_key? book_title then
        @statistics[:books][book_title] = {:a => author_name, :h => 0, :r => []}
      end
      @statistics[:books][book_title][:h] += hours
      @statistics[:books][book_title][:r].push(reader_name)
      @statistics[:books][book_title][:r].uniq!
    end
end