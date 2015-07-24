class Book
  attr_accessor :author, :title, :published
   
  def initialize author, title
    @author = author
    @title = title
#    @author.books << published
  end

end
