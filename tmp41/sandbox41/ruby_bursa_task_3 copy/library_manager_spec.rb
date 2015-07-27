require './library_manager.rb'

describe LibraryManager do
  
  # let(:leo_tolstoy) do
  #   Author.new(1828, 1910, 'Leo Tolstoy' ) 
  # end
  # let!(:oscar_wilde) { Author.new(1854, 1900, 'Oscar Wilde') }
  # let!(:war_and_peace) { PublishedBook.new(leo_tolstoy, 'War and Peace', 1400, 3280, 1996) }
  # let!(:ivan) {Reader.new('Ivan Testenko', 16)}
  # let!(:ivan_testenko) { ReaderWithBook.new(war_and_peace, ivan, 328, (DateTime.now.new_offset(0) + 2.days)) }
  # let!(:manager) { LibraryManager.new([],[], [ivan_testenko]) }

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
                                     DateTime.now.new_offset(0) + 36.hours)
   
  nikolay = Reader.new('Nikolay Vasiliev', 20)
  vasiliev_nikolay = ReaderWithBook.new(dorian_grey, nikolay, 100,
                                        DateTime.now.new_offset(0) + 24.hours)
   
  vasiliy = Reader.new('Vasiliy Pupkin', 15)
  vasily_pupkin = ReaderWithBook.new(the_financier, vasiliy, 500)
   
  john = Reader.new('John Smith', 10)
   
  manager = LibraryManager.new([ivan, nikolay, john],
   
                               [war_and_peace, dorian_grey,
                                fahrenheit451, dandellion_wine,
                                dandellion_wine, dandellion_wine,
                                anna_karenina, the_financier],
   
                               [ivan_testenko, vasiliev_nikolay, vasily_pupkin])

  it 'should compose reader notification' do
    expect(manager.reader_notification("Ivan Testenko")). to eq <<-TEXT
Dear Ivan Testenko!

You should return a book "War and Peace" authored by Leo Tolstoy in 36 hours.
Otherwise you will be charged $12.3 per hour.
By the way, you are on 333 page now and you need 5.4 hours to finish reading "War and Peace"
TEXT
  end

  it 'should compose librarian notification' do
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
    expect(manager.statistics_notification). to eq <<-TEXT
Hello,

The library has: 5 books, 4 authors, 6 readers
The most popular author is Leo Tolstoy: 2450 pages has been read in 2 books by 4 readers.
The most productive reader is Ivan Testenko: he had read 1040 pages in 3 books authored by 3 authors.
The most popular book is "The Well-Grounded Rubyist" authored by David A. Black: it had been read for 123.0 hours by 5 readers.
TEXT
  end
  
end
