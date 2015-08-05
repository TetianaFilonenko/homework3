require 'gmail'
require 'pry'
require 'zip'
require 'csv'
require 'active_support/all'

desc "Make coffee"
task :download_homeworks_and_unzip do
  results = []
  students = []
  Gmail.connect('test', '<test></test>').mailbox("HomeWork3").emails.each_with_index do |email, counter|
    begin
      puts '=' * 80
      student_name = email.message.subject.split('.')[0]
      next if students.include?(student_name)
      students << student_name
      puts "checking #{student_name}, #{counter}"
      student_grade = [counter, student_name]
      FileUtils.mkdir "#{Dir.pwd}/tmp#{counter}"
      FileUtils.mkdir "#{Dir.pwd}/tmp#{counter}/sandbox#{counter}"
      email.message.attachments.each do |f|
        File.write(File.join("#{Dir.pwd}/tmp#{counter}", 'ruby_bursa_task_3.zip'), f.body.decoded)
      end
      Zip::File.open("#{Dir.pwd}/tmp#{counter}/ruby_bursa_task_3.zip") do |zip_file|
        zip_file.each { |f| zip_file.extract(f, File.join("#{Dir.pwd}/tmp#{counter}/sandbox#{counter}", f.name)) }
      end
      puts student_grade.to_s
      results << student_grade
    rescue Exception => e  
      puts e.message
      puts e.backtrace.inspect  
    end
  end
  CSV.open("hw_3_grades.csv", "a+") do |csv|
    results.each{ |res| csv << res }
  end
end

desc "Make tea"
task :check_homework do
  results = []
  file_name = 'library_manager'
  homework_count = Dir.entries('.').reject{ |d| d.scan(/tmp.*/).empty? }.sort_by{ |q| q.split('tmp')[1].to_i }
  homework_count.each do |dir|
    begin
      counter = dir.split('tmp')[1]
      # next if counter.to_i > 3
      puts '=' * 80
      puts dir
      path = "./#{dir}/sandbox#{counter}/#{file_name}.rb"
      directories = Dir.glob("./#{dir}/sandbox#{counter}/*").select{ |e| File.directory? e }
      if directories.present?
        path = directories[0]+"/#{file_name}.rb"
      end  
      if File.exist?(path)
        require path
      else
        raise 'file not found' 
      end

      @leo_tolstoy = Author.new(1828, 1910, 'Leo Tolstoy')
      @oscar_wilde = Author.new(1854, 1900, 'Oscar Wilde')
      @agatha_christie = Author.new(1890, 1976, 'Agatha Christie')

      @war_and_peace = PublishedBook.new(@leo_tolstoy, 'War and Peace', 1400, 3280, 1996)
      @picture_of_dorian_gray = PublishedBook.new(@oscar_wilde, 'The Picture of Dorian Gray', 900, 1280, 2001)
      @poirot_investigates =  PublishedBook.new(@agatha_christie, 'Poirot investigates', 700, 2280, 2007)
      @books = [@war_and_peace, @picture_of_dorian_gray, @poirot_investigates]

      @ivan_testenko = Reader.new('Ivan Testenko', 130)
      @semen_pyatochkin = Reader.new('Semen Pyatochkin', 110)
      @vasya_pupkin = Reader.new('Vasya Pupkin', 140)

      @readers = [@ivan_testenko, @semen_pyatochkin, @vasya_pupkin]

      @ivan_testenko_war_and_peace = ReaderWithBook.new(@war_and_peace, @ivan_testenko, 234, Time.now + 4.days)
      @semen_pyatochkin_dorian_gray = ReaderWithBook.new(@picture_of_dorian_gray, @semen_pyatochkin, 571, Time.now + 1.days) # the most popular book
      @semen_pyatochkin_poirot_investigates = ReaderWithBook.new(@poirot_investigates, @semen_pyatochkin, 464, Time.now + 2.weeks)
      @vasya_pupkin_poirot_investigates = ReaderWithBook.new(@poirot_investigates, @vasya_pupkin, 100, Time.now + 4.days)

      @readers_with_book = [@ivan_testenko_war_and_peace, @semen_pyatochkin_dorian_gray, @semen_pyatochkin_poirot_investigates, @vasya_pupkin_poirot_investigates]

      @manager = LibraryManager.new(@readers, @books, @readers_with_book)

      first, second, third = 3.times.map{0}
      begin
        if @manager.methods.include? :reader_notification
          if @manager.method(:reader_notification).parameters.count == 1
            first += 2
            result = @manager.reader_notification(@ivan_testenko.name).gsub(/\"/,"") 
            first += 2 if (/Dear (.*?)!/.match(result); $1.try(:include?, @ivan_testenko.name))
            first += 2 if (/book(.*?)authored/.match(result); $1.try(:include?, @war_and_peace.title))
            first += 2 if (/on(.*?)page/.match(result); $1.try(:include?, @ivan_testenko_war_and_peace.current_page.to_s))
            first += 2 if (/need(.*?)hours/.match(result); $1.try(:include?, '23.43')) #((@war_and_peace.pages_quantity - @ivan_testenko_war_and_peace.current_page).to_f / @ivan_testenko.reading_speed.to_f).round(2)
          end
        end
      rescue Exception => e
        puts e.message
        puts e.backtrace.inspect
      end
      begin
        if @manager.methods.include? :librarian_notification
          if @manager.method(:librarian_notification).parameters.count.zero?
            second += 2
            result = @manager.librarian_notification.gsub(/\"/,"")
            second += 2 if (/are(.*?)published/.match(result); $1.try(:strip) == "3")
            second += 2 if (/are(.*?)published/.match(result); $1.try(:strip) == "7")
            second += 2 if (/are(.*?)readers and(.*?)of/.match(result); [$1, $2].map(&:strip) == [@readers.count.to_s, @readers_with_book.count.to_s])
            second += 2 if (/are(.*?)readers and(.*?)of/.match(result); [$1, $2].map(&:strip) == [(@readers.count+@readers_with_book.count).to_s, @readers_with_book.count.to_s])
            second += 2 if (/Vasya Pupkin(.*?)Poirot investigates/.match(result); $1.try(:strip) == "is reading")
            second += 2 if result.gsub(' ','').include?(@vasya_pupkin_poirot_investigates.return_date.strftime("%Y-%m-%d at%l%p").downcase.gsub(' ',''))
          end
        end
      rescue Exception => e
        puts e.message
        puts e.backtrace.inspect
      end
      begin
        if @manager.methods.include? :statistics_notification
          if @manager.method(:statistics_notification).parameters.count.zero?
            third += 2
            result = @manager.statistics_notification.gsub(/\"/,"") 
            third += 2 if (/library has:(.*?)books,(.*?)authors,(.*?)readers/.match(result); [$1, $2, $3].map{ |i| i.try(:strip) } == ["3", "3", "3"])
            third += 2 if (/library has:(.*?)books,(.*?)authors,(.*?)readers/.match(result); [$1, $2, $3].map{ |i| i.try(:strip) } == ["7", "3", "7"])
            third += 2 if (/popular author is(.*?):(.*?)pages/.match(result); [$1, $2].map{ |i| i.try(:strip) } == [@oscar_wilde.name, "571"])
            third += 2 if (/productive reader is(.*?): he had read(.*?)pages in (.*?) books authored by (.*?) author/.match(result); [$1, $2, $3, $4].map{ |i| i.try(:strip) } == [@semen_pyatochkin.name, "1035", "2", "2"]) 
            third += 2 if (/popular book is(.*?)authored by (.*?):/.match(result);  [$1, $2].map{ |i| i.try(:strip) } == [@picture_of_dorian_gray.title, @oscar_wilde.name])
          end
        end
      rescue Exception => e
        puts e.message
        puts e.backtrace.inspect
      end
      
      [:LibraryManager, :Author, :Book, :PublishedBook, :Reader,
       :ReaderWithBook].each{ |s| Object.send(:remove_const, s) }
      total = [first, second, third].sum
      student_grade = [counter, total, first, second, third]
      results << student_grade
    rescue Exception => e  
      puts e.message
      puts e.backtrace.inspect  
    end
  end
  CSV.open("hw_3_grades.csv", "a+") do |csv|
    results.each{ |res| csv << res }
  end
end

desc "And clear"
task :remove_homeworks do
  results = []
  begin
    system('rm -rf tmp*')
  rescue Exception => e  
    puts e.message
    puts e.backtrace.inspect  
  end
  CSV.open("hw_3_grades.csv", "a+") do |csv|
    results.each{ |res| csv << res }
  end
end