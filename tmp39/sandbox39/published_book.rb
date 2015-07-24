class PublishedBook < Book
  attr_accessor :price, :pages_quantity, :published_at

  def initialize author, title, price, pages_quantity, published_at
    @price = price
    @pages_quantity = pages_quantity
    @published_at = published_at
    super author, title
  end

  def age_years year = Time.now.year
    year - published_at + 1
  end

  def penalty_per_hour year = Time.now.year
    age = age_years year
    price_penalty = price * 0.0005
    pages_penalty = 0.000003 * price * pages_quantity
    age_penalty = 0.00007 * price * age

    price_penalty + pages_penalty + age_penalty
  end

  def self.find books, book_title
    books.each do |book|
      if book.title == book_title
        return book
      end
    end
    nil
  end 
end
