require './library_manager.rb'

describe LibraryManager do

  let(:leo_tolstoy) {Author.new(1828, 1910, 'Leo Tolstoy') }
  let(:war_and_peace) {PublishedBook.new(leo_tolstoy, 'War and Peace', 1400, 3280, 1996)}
  let(:war_and_peace_2) {PublishedBook.new(leo_tolstoy, 'War and Peace 2', 1100, 3000, 1999)}
 
  let(:oscar_wilde) { Author.new(1854, 1900, 'Oscar Wilde')}
 
  let(:red_and_black) {PublishedBook.new(oscar_wilde, 'Red and Black', 1300, 150, 2000)}
  let(:red_and_black_2) {PublishedBook.new(oscar_wilde, 'Red and Black 2', 1800, 1500, 2001)} 

  let(:david_black) {Author.new(1851, 1900, 'David A. Black')}
  
  let(:grounded_rubyist) {PublishedBook.new(david_black, 'The Well-Grounded Rubyist', 2000, 10000, 2005)}

  let(:ivan) {Reader.new('Ivan Testenko', 16)}
  let(:ivan_testenko_with_book) {ReaderWithBook.new(war_and_peace, ivan, 333, (DateTime.now.new_offset(0) + 2.weeks))}
  
  let(:petrenko) {Reader.new('Ivan Petrenko', 18)}
  let(:petrenko_with_book) {ReaderWithBook.new(war_and_peace_2, petrenko, 100, (DateTime.now.new_offset(0) + 2.weeks))}
  
  let(:obama) {Reader.new('Barak Obama', 20)}   
  let(:obama_with_book) {ReaderWithBook.new(red_and_black, obama, 50, (DateTime.now.new_offset(0) + 2.weeks))}

  let(:stepan) {Reader.new('Barak Stepan', 10)}  
 
  let(:manager) {LibraryManager.new([stepan], [red_and_black_2, grounded_rubyist], [ivan_testenko_with_book, petrenko_with_book, obama_with_book])}
   
  it 'should compose reader notification = Ivan Testenko' do

    expect(manager.reader_notification "Ivan Testenko"). to eq <<-TEXT
Dear Ivan Testenko!

You should return a book "War and Peace" authored by Leo Tolstoy in 336.00 hours.
Otherwise you will be charged $0.16 per hour.
By the way, you are on 333 page now and you need 184.19 hours to finish reading "War and Peace"
TEXT
   end

    it 'should compose reader notification = Barak Obama' do

    expect(manager.reader_notification "Barak Obama"). to eq <<-TEXT
Dear Barak Obama!

You should return a book "Red and Black" authored by Oscar Wilde in 336.00 hours.
Otherwise you will be charged $0.03 per hour.
By the way, you are on 50 page now and you need 5.00 hours to finish reading "Red and Black"
TEXT
   end

  it 'should compose librarian notification' do
 
    expect(manager.librarian_notification). to eq <<-TEXT
Hello,

There are 5 published books in the library.
There are 4 readers and 3 of them are reading the books.

Ivan Testenko is reading "War and Peace" - should return on 2015-07-22 at 2pm - 184.19 hours of reading is needed to finish.
Ivan Petrenko is reading "War and Peace 2" - should return on 2015-07-22 at 2pm - 161.11 hours of reading is needed to finish.
Barak Obama is reading "Red and Black" - should return on 2015-07-22 at 2pm - 5.00 hours of reading is needed to finish.
TEXT
  end

  it 'should compose statistics notification' do
 
    expect(manager.statistics_notification). to eq <<-TEXT
Hello,

The library has: 5 books, 3 authors, 4 readers
The most popular author is Leo Tolstoy: 433 pages has been read in 2 books by 2 readers.
The most productive reader is Ivan Testenko: he had read 333 pages in 1 books authored by 1 authors.
The most popular book is "War and Peace" authored by Leo Tolstoy: it had been read for 20.81 hours by 1 readers.
TEXT
  end
      
end
