require 'active_support/all'
require 'pry'

require_relative 'author.rb'
require_relative 'book.rb'
require_relative 'published_book.rb'
require_relative 'reader.rb'
require_relative 'reader_with_book.rb'

describe ReaderWithBook do
  
  let(:leo_tolstoy) { Author.new(1828, 1910, 'Leo Tolstoy' ) }
  let(:ivan_testenko_reader) { Reader.new('Ivan Testenko', 100) }
  let(:war_and_peace) { PublishedBook.new(leo_tolstoy, 'War and Peace', 1400, 3280, 1996) }
  let(:reader_with_book) { ReaderWithBook.new(war_and_peace, ivan_testenko_reader, 328, (Time.now - 2.days)) }
    
  it 'should count penalty' do
    expect(reader_with_book.penalty).to eq 789
  end

  it 'should count days to buy' do
    expect(reader_with_book.days_to_buy).to eq 4
  end

  it 'should count penalty to finish' do
    expect(reader_with_book.penalty_to_finish).to eq 1274
  end

end