class Author
  attr_accessor :year_of_birth, :year_of_death, :name

  def initialize year_of_birth, year_of_death, name
    @year_of_birth = year_of_birth
    @year_of_death = year_of_death
    @name = name
  end

  def self.find_authors readers_with_books
    authors = []
    readers_with_books.each do |reader_with_book|
       authors << reader_with_book.amazing_book.author
    end
    authors.uniq
  end
end
