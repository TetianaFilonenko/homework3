require './library_manager.rb'

describe LibraryManager do

  let(:leo_tolstoy) { Author.new(1828, 1910, 'Leo Tolstoy' ) }
  let(:war_and_peace) { PublishedBook.new(leo_tolstoy, 'War and Peace', 1400, 3280, 1996) }
  let(:ivan) {Reader.new('Ivan Testenko', 16)}
  let(:ivan_testenko) { ReaderWithBook.new(war_and_peace, ivan, 328, (DateTime.now.new_offset(0) + 2.days)) }
  let(:manager) { LibraryManager.new([],[], [ivan_testenko]) }

  before(:each) do
    manager.new_book(Author.new(1783, 1942, 'Stendhal'), 'Red and Black', 857, 400, 2001) 
    manager.new_book(Author.new(1950, 2999, 'David A. Black'), 'The Well-Grounded Rubyist', 2734, 520, 2014) 
    manager.new_book(Author.new(1950, 2999, 'David A. Black'), 'Ruby for Rails', 3599, 532, 2006) 
    manager.new_book(Author.new(1854, 1900, 'Oscar Wilde'), 'The Picture of Dorian Gray', 210, 254, 1993) 
    manager.new_reader('Barak Obama', 18)
    manager.new_reader('Vasiliy Pupkin', 12)
    manager.new_reader('Michael Saakashvili', 22)
    manager.new_reader('Goga Gopnik', 3)
    manager.new_reader('Sviatoslav Vakarchuk', 25)
    manager.give_book_to_reader('Vasiliy Pupkin','Red and Black') 
    manager.give_book_to_reader('Barak Obama','The Well-Grounded Rubyist') 
    manager.read_the_book('Vasiliy Pupkin',30)
    manager.read_the_book('Barak Obama',20)
  end
  
  it 'should compose reader notification' do
    #binding.pry
    expect(manager.reader_notification("Ivan Testenko")). to eq <<-TEXT
Dear Ivan Testenko!
You should return a book "War and Peace" authored by Leo Tolstoy in 48 hours.
Otherwise you will be charged $0.16 per hour.
By the way, you are on 328 page now and you need 184.5 hours to finish reading "War and Peace"
TEXT
  end

  it 'should compose librarian notification' do
    expect(manager.librarian_notification). to eq <<-TEXT
Hello,
There are 5 published books in the library.
There are 6 readers and 3 of them are reading the books.
Ivan Testenko is reading "War and Peace" - should return on 2015-07-10 at 20pm - 184.5 hours of reading is needed to finish.
Vasiliy Pupkin is reading "Red and Black" - should return on 2015-07-18 at 20pm - 3.33 hours of reading is needed to finish.
Barak Obama is reading "The Well-Grounded Rubyist" - should return on 2015-07-18 at 20pm - 8.89 hours of reading is needed to finish.

TEXT
  end

  it 'should compose statistics notification' do
    expect(manager.statistics_notification). to eq <<-TEXT
Hello,
The library has: 5 books, 4 authors, 6 readers
The most popular author is Stendhal: 360 pages has been read in 1 books by 1 readers.
The most productive reader is Vasiliy Pupkin: he had read 360 pages in 1 books authored by 1 authors.
The most popular book is "Red and Black" authored by Stendhal: it had been read for 30.0 hours by 1 readers.
TEXT
  end
  
end
