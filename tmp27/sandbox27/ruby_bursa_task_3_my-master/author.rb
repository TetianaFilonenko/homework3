class Author
  attr_accessor :year_of_birth, :year_of_death, :name, :books

  def initialize year_of_birth, year_of_death, name
    @year_of_birth = year_of_birth
    @year_of_death = year_of_death
    @name = name
    @books = []
  end

  def can_meet? other_author
        first = (@year_of_birth..@year_of_death).to_a
        second = (other_author.year_of_birth..other_author.year_of_death).to_a
        return (first & second).count>0 ? true : false
  end

  def transliterate
            dictionary = {"А"=>"A",
                  "а"=>"a",
                  "Б"=>"B",
                  "б"=>"b",
                  "В"=>"V",
                  "в"=>"v",
                  "Г"=>"H",
                  "г"=>"h",
                  "Ґ"=>"G",
                  "ґ"=>"g",
                  "Д"=>"D",
                  "д"=>"d",
                  "Е"=>"E",
                  "е"=>"e",
                  "Є"=>"Ye",
                  "є"=>"ie",
                  "Ж"=>"Zh",
                  "ж"=>"zh",
                  "З"=>"Z",
                  "з"=>"z",
                  "И"=>"Y",
                  "и"=>"y",
                  "І"=>"I",
                  "і"=>"i",
                  "Ї"=>"Yi",
                  "ї"=>"i",
                  "Й"=>"Y",
                  "й"=>"i",
                  "К"=>"K",
                  "к"=>"k",
                  "Л"=>"L",
                  "л"=>"l",
                  "М"=>"M",
                  "м"=>"m",
                  "Н"=>"N",
                  "н"=>"n",
                  "О"=>"O",
                  "о"=>"o",
                  "П"=>"P",
                  "п"=>"p",
                  "Р"=>"R",
                  "р"=>"r",
                  "С"=>"S",
                  "с"=>"s",
                  "Т"=>"T",
                  "т"=>"t",
                  "У"=>"U",
                  "у"=>"u",
                  "Ф"=>"F",
                  "ф"=>"f",
                  "Х"=>"Kh",
                  "х"=>"kh",
                  "Ц"=>"Ts",
                  "ц"=>"ts",
                  "Ч"=>"Ch",
                  "ч"=>"ch",
                  "Ш"=>"Sh",
                  "ш"=>"sh",
                  "Щ"=>"Shch",
                  "щ"=>"shch",
                  "Ю"=>"Yu",
                  "ю"=>"iu",
                  "Я"=>"Ya",
                  "я"=>"ia",
                  "’"=>"",
                  "'"=>"",
                  "`"=>""
                  }
    tmp_name = ""

    @name.strip.split.each {|x| tmp_name << x.mb_chars.capitalize.to_s + " "}
    @name = tmp_name.strip

    dictionary.each {|key, value| @name = @name.gsub(key,value) }
 
   return @name
  end

end
