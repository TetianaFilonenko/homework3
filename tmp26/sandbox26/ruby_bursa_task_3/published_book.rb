class PublishedBook < Book

  attr_accessor :price, :pages_quantity, :published_at

  def initialize author, title, price, pages_quantity, published_at
    super author, title
    @price, @pages_quantity, @published_at = price, pages_quantity, published_at
  end

  def age
    Time.now.year - published_at + 1
  end

  def penalty_per_hour
    price_penalty = 0.0005   * price
    pages_penalty = 0.000003 * price * pages_quantity
    age_penalty   = 0.00007  * price * age

    price_penalty + pages_penalty + age_penalty
  end

end
