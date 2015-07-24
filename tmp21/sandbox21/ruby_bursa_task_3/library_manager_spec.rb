require './author.rb'
require './library_manager.rb'

describe LibraryManager do
#Library
  let(:manager) {LibraryManager.new}

#Authors
  let(:leo_tolstoy) { Author.new(1828, 1910, 'Leo Tolstoy' ) }
  let(:oscar_wilde) { Author.new(1854, 1900, 'Oscar Wilde') }
  let(:stendhal) { Author.new(1783, 1842, 'Stendhal') }
  let(:devid_black) { Author.new(nil, nil, 'David A. Black') }

#Books
  let(:war_and_peace) {manager.new_book(leo_tolstoy, 'War and Peace', 1054, 3280, 1996) }
  let(:red_and_black) {manager.new_book(stendhal, 'Red and Black', 800, 457, 2010) }
  let(:rubyist) {manager.new_book(devid_black, 'The Well-Grounded Rubyist', 5000, 487, 2014) }
  let(:grey)    { manager.new_book( oscar_wilde, 'The Picture of Dorian Gray',1600, 617, 2010) }
  let(:karenina){ manager.new_book( leo_tolstoy, 'Anna Karenina', 1199, 987, 2003) }

#Readers
  let(:teslenko) {manager.new_reader('Ivan Testenko', 546)}
  let(:pupkin) {manager.new_reader('Vasiliy Pupkin', 10)}
  let(:obama) {manager.new_reader('Barak Obama', 5)}
  let(:matz) {manager.new_reader('Yukihiro Matsumoto', 55)}
  let(:knuth) {manager.new_reader('Donald Knuth', 2)}
  let(:carmack) {manager.new_reader('John Carmack', 35)}


  it 'creates new instanse' do;  expect{manager}.to_not raise_error ; end

  it 'adds new book' do
    expect( war_and_peace.title ).to eq 'War and Peace'
    expect( red_and_black.author ).to eq stendhal
    expect( rubyist.price ).to eq 5000
    expect( war_and_peace.pages_quantity ).to eq 3280
    expect( war_and_peace.published_at ).to eq 1996
  end

  it 'adds new reader' do
    expect(teslenko.name).to eq 'Ivan Testenko'
    expect(pupkin.reading_speed).to eq 10
  end

#LOOK 
  it 'gives book to reader if readers name and books title are valid' do
    teslenko
    pupkin
    war_and_peace
    red_and_black
    rubyist
    book = manager.give_book_to_reader 'Ivan Testenko', 'Red and Black'
    expect( book.reader.name ).to eq 'Ivan Testenko'
    expect( book.amazing_book.title ).to eq 'Red and Black'
  end

  it 'updates current page' do
    obama
    rubyist
    manager.give_book_to_reader 'Barak Obama', 'The Well-Grounded Rubyist'
    reader_book = manager.read_the_book 'Barak Obama', 2
    reader_book = manager.read_the_book 'Barak Obama', 5
    expect( reader_book.current_page ).to eq (2+5)*5

  end
  
  it 'should compose reader notification' do
    teslenko
    war_and_peace
    rwb = manager.give_book_to_reader 'Ivan Testenko', 'War and Peace'
    rwb.return_date = Time.now + 36.hours
    rwb.current_page = 333
    expect(manager.reader_notification("Ivan Testenko")). to eq <<-TEXT
Dear Ivan Testenko!

You should return a book "War and Peace" authored by Leo Tolstoy in 36.0 hours.
Otherwise you will be charged $12.3 per hour.
By the way, you are on 333 page now and you need 5.4 hours to finish reading "War and Peace"
TEXT
  end

  it 'should compose librarian notification' do
    teslenko = manager.new_reader('Ivan Testenko', 656)
    pupkin = manager.new_reader('Vasiliy Pupkin', 40)
    obama = manager.new_reader('Barak Obama', 10)
    matz; carmack; knuth
    war_and_peace 
    red_and_black = manager.new_book(stendhal, 'Red and Black', 800, 508, 2010)
    rubyist = manager.new_book(devid_black, 'The Well-Grounded Rubyist', 5000, 445, 2014)
    grey; karenina
    manager.give_book_to_reader('Ivan Testenko', 'War and Peace').return_date = Time.new(2015,7,4,10)
    manager.give_book_to_reader('Vasiliy Pupkin', 'Red and Black').return_date = Time.new(2015,7,12,19)
    manager.give_book_to_reader('Barak Obama', 'The Well-Grounded Rubyist').return_date = Time.new(2015,7,10,12)
    expect(manager.librarian_notification). to eq <<-TEXT
Hello,

There are 5 published books in the library.
There are 6 readers and 3 of them are reading the books.

Ivan Testenko is reading "War and Peace" - should return on 2015-07-04 at 10am - 5.0 hours of reading is needed to finish.
Vasiliy Pupkin is reading "Red and Black" - should return on 2015-07-12 at 7pm  - 12.7 hours of reading is needed to finish.
Barak Obama is reading "The Well-Grounded Rubyist" - should return on 2015-07-10 at 12pm  - 44.5 hours of reading is needed to finish.
TEXT
  end

  it 'should compose statistics notification' do
    # teslenko = manager.new_reader('Ivan Testenko', 656)
    # pupkin = manager.new_reader('Vasiliy Pupkin', 40)
    # obama = manager.new_reader('Barak Obama', 10)
    # matz; carmack; knuth
    # war_and_peace 
    # red_and_black = manager.new_book(stendhal, 'Red and Black', 800, 508, 2010)
    # rubyist = manager.new_book(devid_black, 'The Well-Grounded Rubyist', 5000, 445, 2014)
    # grey; karenina
    # manager.give_book_to_reader('Ivan Testenko', 'War and Peace').return_date = Time.new(2015,7,4,10)
    # manager.give_book_to_reader('Vasiliy Pupkin', 'Red and Black').return_date = Time.new(2015,7,12,19)
    # manager.give_book_to_reader('Barak Obama', 'The Well-Grounded Rubyist').return_date = Time.new(2015,7,10,12)


    teslenko  = Reader.new('Ivan Testenko', 656)
    pupkin    = Reader.new('Vasiliy Pupkin', 40)
    obama     = Reader.new('Barak Obama', 10)
    matz      = Reader.new('Yukihiro Matsumoto', 55)
    knuth     = Reader.new('Donald Knuth', 1)
    carmack   = Reader.new('John Carmack', 35)

    leo_tolstoy = Author.new(1828, 1910, 'Leo Tolstoy' )
    oscar_wilde = Author.new(1854, 1900, 'Oscar Wilde')
    stendhal    = Author.new(1783, 1842, 'Stendhal')
    devid_black = Author.new(nil, nil, 'David A. Black')

    war_and_peace = PublishedBook.new(leo_tolstoy, 'War and Peace',              105420, 3280, 1996)
    red_and_black = PublishedBook.new(stendhal,    'Red and Black',              800,    457,  2010)
    rubyist       = PublishedBook.new(devid_black, 'The Well-Grounded Rubyist',  5000,   487,  2014)
    grey          = PublishedBook.new(oscar_wilde, 'The Picture of Dorian Gray', 1600,   617,  2010)
    karenina      = PublishedBook.new(leo_tolstoy, 'Anna Karenina',              1199,   987,  2003)

    manager = LibraryManager.new(
      [teslenko, pupkin, obama, matz, knuth, carmack],
      [war_and_peace, red_and_black, rubyist, grey, war_and_peace],
      [ ReaderWithBook.new(war_and_peace, teslenko, 1000, (Time.now + 2.weeks)),
        ReaderWithBook.new(war_and_peace, obama, 600, (Time.now + 2.weeks)),
        ReaderWithBook.new(war_and_peace, pupkin, 750, (Time.now + 2.weeks)),
        ReaderWithBook.new(red_and_black, teslenko, 0, (Time.now + 2.weeks)),
        ReaderWithBook.new(war_and_peace, matz, 100, (Time.now + 2.weeks)),
        ReaderWithBook.new(rubyist, teslenko, 40, (Time.now + 2.weeks)), 
        ReaderWithBook.new(rubyist, knuth,    120, (Time.now + 2.weeks)),
        ReaderWithBook.new(rubyist, pupkin, 100, (Time.now + 2.weeks)),
        ReaderWithBook.new(rubyist, matz, 24, (Time.now + 2.weeks)),
        ReaderWithBook.new(rubyist, carmack, 0, (Time.now + 2.weeks))]
      )

    expect(manager.statistics_notification). to eq <<-TEXT
Hello,

The library has: 5 books, 4 authors, 6 readers
The most popular author is Leo Tolstoy: 2450 pages has been read in 4 books by 4 readers.
The most productive reader is Ivan Testenko: he had read 1040 pages in 3 books authored by 3 authors.
The most popular book is "The Well-Grounded Rubyist" authored by David A. Black: it had been read for 123.0 hours by 5 readers.
TEXT
  end
  
end
