require './library_manager.rb'

describe LibraryManager do
#Add manager
  let!(:manager) { LibraryManager.new }

#Add authors
  let!(:leo_tolstoy) { manager.new_author(1828, 1910, 'Leo Tolstoy') }
  let!(:stendhal) { manager.new_author(1783, 1842, 'Stendhal') }
  let!(:dblack) { manager.new_author(1960, 2050, 'David Black') }
  let!(:owild) { manager.new_author(1854, 1890, 'Oscar Wilde') }

#Add books
  let!(:war_and_peace) { manager.new_book(leo_tolstoy, 'War and Peace', 50000, 3280, 1800) } 
  let!(:anna_karenina) { manager.new_book(leo_tolstoy, 'Anna Karenina', 2400, 864, 1877) } 
  let!(:cossacks) { manager.new_book(leo_tolstoy, 'The Cossacks', 2800, 161, 1863) } 
  let!(:red_and_black) { manager.new_book(stendhal, 'The Red and the Black', 1300, 843, 1830) }
  let!(:well_grounded_rubyist) { manager.new_book(dblack, 'The Well-Grounded Rubyist', 5000, 520, 2009) }

#Add readers
  let!(:ivan_reader) { manager.new_reader('Ivan Testenko', 15) }
  let!(:vasiliy_reader) { manager.new_reader('Vasiliy Pupkin', 20) }
  let!(:barak_reader) { manager.new_reader('Barak Obama', 22) }
  let!(:ivan_grozniy) { manager.new_reader('Ivan Grozniy', 24) }
  let!(:sergei_perevertailo) { manager.new_reader('Sergei Perevertailo', 29) }
  let!(:yuriy_gagarin) { manager.new_reader('Yuriy Gagarin', 30) }



  it 'should compose reader notification' do
#binding.pry
    manager.give_book_to_reader(ivan_reader.name, war_and_peace.title, Time.now + 36.hours)
    manager.read_the_book("Ivan Testenko", 20)
    expect(manager.reader_notification("Ivan Testenko")). to eq <<-TEXT
Dear Ivan Testenko!

You should return a book "War and Peace" authored by Leo Tolstoy in 36 hours.
Otherwise you will be charged $12.7 per hour.
By the way, you are on 300 page now and you need 198.7 hours to finish reading "War and Peace"
TEXT
  end

  it 'should compose librarian notification' do
    ivan = manager.give_book_to_reader(ivan_reader.name, war_and_peace.title, Time.now + 36.hours)
    vasiliy = manager.give_book_to_reader(vasiliy_reader.name, anna_karenina.title, Time.now + 24.hours)
    barak = manager.give_book_to_reader(barak_reader.name, cossacks.title, Time.now + 36.hours)
#binding.pry

    expect(manager.librarian_notification). to eq <<-TEXT
Hello,

There are 5 published books in the library.
There are 6 readers and 3 of them are reading the books.

#{ivan.reader.name} is reading "#{ivan.book.title}" - should return on #{ivan.return_date.strftime("%Y-%m-%d")} at #{ivan.return_date.strftime("%l%P")} - #{ivan.hours_to_deadline.round(1)} hours of reading is needed to finish.
#{vasiliy.reader.name} is reading "#{vasiliy.book.title}" - should return on #{vasiliy.return_date.strftime("%Y-%m-%d")} at #{vasiliy.return_date.strftime("%l%P")} - #{vasiliy.hours_to_deadline.round(1)} hours of reading is needed to finish.
#{barak.reader.name} is reading "#{barak.book.title}" - should return on #{barak.return_date.strftime("%Y-%m-%d")} at #{barak.return_date.strftime("%l%P")} - #{barak.hours_to_deadline.round(1)} hours of reading is needed to finish.

TEXT
  end

  it 'should compose statistics notification' do
    manager.give_book_to_reader(ivan_reader.name, war_and_peace.title, Time.now + 36.hours)
    manager.give_book_to_reader(vasiliy_reader.name, anna_karenina.title, Time.now + 24.hours)
    manager.give_book_to_reader(barak_reader.name, red_and_black.title, Time.now + 36.hours)
    manager.give_book_to_reader(ivan_grozniy.name, well_grounded_rubyist.title, Time.now + 36.hours)


    manager.read_the_book("Ivan Testenko", 20)
    manager.read_the_book("Vasiliy Pupkin", 10)
    manager.read_the_book("Barak Obama", 20)
    manager.read_the_book("Ivan Grozniy", 20)

    manager.give_book_to_reader(vasiliy_reader.name, cossacks.title, Time.now + 36.hours)
    manager.read_the_book("Vasiliy Pupkin", 10)

binding.pry
    expect(manager.statistics_notification). to eq <<-TEXT
Hello,

The library has: 5 books, 4 authors, 6 readers
The most popular author is Leo Tolstoy: 2450 pages has been read in 2 books by 4 readers.
The most productive reader is Ivan Testenko: he had read 1040 pages in 3 books authored by 3 authors.
The most popular book is "The Well-Grounded Rubyist" authored by David A. Black: it had been read for 123.0 hours by 5 readers.
TEXT
  end
end
