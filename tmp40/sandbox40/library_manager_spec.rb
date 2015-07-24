require './library_manager.rb'


describe LibraryManager do
  let!(:stendhal) { Author.new(1783, 1842, 'Stendhal' ) }
  let!(:nietzsche ) { Author.new(1844, 1900, 'Friedrich Nietzsche' ) }
  let!(:leo_tolstoy) { Author.new(1828, 1910, 'Leo Tolstoy' ) }
  let!(:some_author) { Author.new(1828, 1910, 'Some Author' ) }
  let!(:some_reader) { Reader.new('Some Reader', 100) }
  let!(:ivan_testenko_reader) { Reader.new('Ivan Testenko', 100) }
  let!(:vasiliy_pupkin_reader) { Reader.new('Vasiliy Pupkin', 10) }
  let!(:barak_obama_reader) { Reader.new('Barak Obama', 10) }
  let!(:war_and_peace) { PublishedBook.new(leo_tolstoy, 'War and Peace', 1400, 3280, 1996) }
  let!(:some_book) { PublishedBook.new(some_author, 'Some book', 1400, 3280, 1996) }
  let!(:zarathustra) { PublishedBook.new(nietzsche, 'Thus Spoke Zarathustra', 1400, 204, 1990) }
  let!(:red_and_black) { PublishedBook.new(stendhal, 'Red and Black', 1400, 3280, 1996) }

  let!(:ivan_and_war_and_peace) { ReaderWithBook.new(war_and_peace, ivan_testenko_reader, 328, (Time.now + 2.days)) }
  let!(:some_reader_with_book) { ReaderWithBook.new(some_book, some_reader, 328, (Time.now + 2.days)) }
  let!(:vasiliy_and_red_and_black) { ReaderWithBook.new(red_and_black, vasiliy_pupkin_reader) }
  let!(:barak_and_zarathustra) { ReaderWithBook.new(zarathustra, barak_obama_reader) }
  let!(:manager) { LibraryManager.new([some_reader], [some_book], [ivan_and_war_and_peace]) }

  it 'should create a new book' do
    manager.new_book(some_author, 'Some book', 1400, 3280, 1996)
    expect(manager.books.length).to eq 2  
  end

  it 'should create a new reader' do
    manager.new_reader('Some Reader', 100)
    expect(manager.readers.length).to eq 2  
  end
 
  it 'should give a book to a reader' do
    manager.new_book(some_author, 'Some book', 1400, 3280, 1996)
    manager.new_reader('Some Reader', 100)
    manager.give_book_to_reader 'Some Reader', 'Some book'
    expect(manager.readers_with_books.length).to eq 2 
  end

  it 'should read a book correctly' do
    manager.read_the_book 'Ivan Testenko', 10
    expect(manager.readers_with_books[0].current_page).to eq 1328
  end

  it 'should compose reader notification' do
  	ivan_and_war_and_peace.return_date += 84.hours
    expect(manager.reader_notification(ivan_and_war_and_peace.reader_name)). to eq <<-TEXT
Dear #{ivan_and_war_and_peace.reader_name}!

You should return a book "#{ivan_and_war_and_peace.book_title}" authored by #{ivan_and_war_and_peace.author_name} in #{((ivan_and_war_and_peace.return_date.to_time.to_i - Time.now.to_i) / 3600.0).round(2)} hours.

Otherwise you will be charged $#{ivan_and_war_and_peace.amazing_book.penalty_per_hour.round / 100.0 } per hour.

By the way, you are on #{ivan_and_war_and_peace.current_page} page now and you need #{ivan_and_war_and_peace.time_to_finish} hours to finish reading "#{ivan_and_war_and_peace.book_title}"
TEXT
  end

  it 'should compose librarian notification' do
    manager.new_reader_with_book(vasiliy_pupkin_reader, red_and_black)
    manager.new_reader_with_book(barak_obama_reader, zarathustra)
    readers_info = ""
    manager.readers_with_books.each do |r|
      readers_info += (r.reader_name + " is reading \"" + r.book_title + "\" - should return on " + r.return_date.strftime("%F") + " at " + r.return_date.strftime("%r") + " - " + (r.time_to_finish.round(2)).to_s + " hours of reading is needed to finish.\n\n")
    end
    expect(manager.librarian_notification). to eq <<-TEXT
Hello,

There are #{manager.books.count + manager.readers_with_books.count} published books in the library.

There are #{manager.readers.count + manager.readers_with_books.count} readers and #{manager.readers_with_books.count} of them are reading the books.

#{readers_info}
TEXT
  end

  it 'should compose statistics notification' do
    manager.new_reader_with_book(vasiliy_pupkin_reader, red_and_black)
    manager.new_reader_with_book(barak_obama_reader, zarathustra)
    manager.read_the_book 'Vasiliy Pupkin', 100
    manager.new_book(some_author, 'Some book', 1400, 3280, 1996)
    expect(manager.statistics_notification). to eq <<-TEXT
Hello,

The library has: #{manager.books.count + manager.readers_with_books.count} books, #{manager.statistics["authors"].count} authors, #{manager.readers.count + manager.readers_with_books.count} readers

The most popular author is Leo Tolstoy: 2450 pages has been read in 2 books by 4 readers.

The most productive reader is Ivan Testenko: he had read 1040 pages in 3 books authored by 3 authors.

The most popular book is "The Well-Grounded Rubyist" authored by David A. Black: it had been read for 123.0 hours by 5 readers.
TEXT
  end
  
end
