require "./library_manager.rb"

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
#puts manager.check_hash
puts

puts 'READER:'
puts manager.reader_notification ivan_testenko.reader.name
puts 'LIBRARIAN:'
puts manager.librarian_notification
puts 'STATISTICS:'
puts manager.statistics_notification
puts '============================='


# -------------------------------
#   require 'pp'
#   def check_hash
#     pp @statistics
#   end
