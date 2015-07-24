require './library_manager.rb'
describe LibraryManager do
let!(:arthur_konan_doyle) { Author.new(1859, 1930, 'Arthur Konan-Doyle') }
let!(:david_black) { Author.new(1958, 2007, 'David A. Black') }
let!(:leo_tolstoy) { Author.new(1828, 1910, 'Leo Tolstoy') }
let!(:stendahl) { Author.new(1783, 1842, 'Stendahl') }
let!(:war_and_peace) { PublishedBook.new('Leo Tolstoy', 'War and Peace', 1400, 3280, 1996) }
let!(:red_and_black) { PublishedBook.new('Stendahl', 'Red and Black', 1220, 543, 2002) }
let!(:the_well_grounded_rubyist) { PublishedBook.new('David A. Black', 'The Well-Grounded Rubyist', 1650, 960, 2006) }
let!(:sherlock) { PublishedBook.new('Arthur Konan-Doyle', 'Sherlock', 1560, 800, 2005) }
let!(:his_last_bow) { PublishedBook.new('Arthur Konan-Doyle', 'His Last Bow', 1000, 470, 1992) }
let!(:ivan) {Reader.new('Ivan Testenko', 16)}
let!(:vasiliy) {Reader.new('Vasiliy Pupkin', 18)}
let!(:barak) {Reader.new('Barak Obama', 22)}
let!(:ivan_a) {Reader.new('Ivan Antonov', 15)}
let!(:anton) {Reader.new('Anton Ivanov', 14)}
let!(:greg) {Reader.new('Gregory House', 23)}
let!(:ivan_testenko) { ReaderWithBook.new(war_and_peace, ivan, 333, (DateTime.now.new_offset(0) + 2.days)) }
let!(:vasiliy_pupkin) { ReaderWithBook.new(red_and_black, vasiliy, 157, (DateTime.now.new_offset(0) + 4.days)) }
let!(:barak_obama) { ReaderWithBook.new(the_well_grounded_rubyist, barak, 670, (DateTime.now.new_offset(0) + 36.hours)) }
let!(:manager) { LibraryManager.new([anton, ivan_a, greg, ivan_testenko, vasiliy_pupkin, barak_obama],[war_and_peace, red_and_black, the_well_grounded_rubyist, sherlock, his_last_bow], ivan_testenko, vasiliy_pupkin, barak_obama) }
it 'should compose reader notification' do
#binding.pry
expect(manager.reader_notification("Ivan Testenko")). to eq <<-TEXT
Dear Ivan Testenko!
You should return a book "War and Peace" authored by Leo Tolstoy in 48.0 hours.
Otherwise you will be charged 16 per hour.
By the way, you are on 333 page now and you need 184.19 hours to finish reading "War and Peace"
TEXT
end
it 'should compose librarian notification' do
expect(manager.librarian_notification). to eq <<-TEXT
Hello,
There are 5 published books in the library.
There are 6 readers and 3 of them are reading the books.
Ivan Testenko is reading "War and Peace" - should return on 2015-07-04 at 10am - 5.0 hours of reading is needed to finish.
Vasiliy Pupkin is reading "Red and Black" - should return on 2015-07-12 at 7pm - 12.7 hours of reading is needed to finish.
Barak Obama is reading "The Well-Grounded Rubyist" - should return on 2015-07-10 at 12pm - 44.5 hours of reading is needed to finish.
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