class PublishedBook < Book
  attr_accessor :price, :pages_quantity, :published_at, :reader, :readed_info

  def initialize author, title, price, pages_quantity, published_at, reader = nil, readed_info = {}
    @price = price
    @pages_quantity = pages_quantity
    @published_at = published_at
    super author, title
    author.books << self
    @reader = reader    
    @readed_info = readed_info    
  end

#  def price_per_hour
#    ( 0.00007 * (Time.now.year - @published_at) * @price) +
#    (0.000003 * @pages_quantity * @price) + (0.0005 * @price)
#  end
  def update_info(reader_name, pages, time)  
    if @readed_info.has_key?(reader_name)
      @readed_info[reader_name][:pages] += pages
      @readed_info[reader_name][:times] += time
      
    else
      @readed_info.merge!({reader_name => {:pages => pages, :times => time}})
    end
  end
  
  def age
    Time.now.year - @published_at
  end

  def penalty_per_hour
    price_penalty = @price * 0.0005
    pages_penalty = 0.000003 * @price * @pages_quantity
    age_penalty = 0.00007 * price * age

    price_penalty + pages_penalty + age_penalty
  end

end
