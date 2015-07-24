class Author
  attr_accessor :year_of_birth, :year_of_death, :name

  def initialize year_of_birth, year_of_death, name
    @year_of_birth = year_of_birth
    @year_of_death = year_of_death
    @name = name
  end

  def to_s
    ret = "#{@name} "
    ret += ( @year_of_birth != nil ? ("(#{@year_of_birth}") : "(???" )
    ret += ( @year_of_death != nil ? (" - #{@year_of_death})"):(")") )
  end

  def ==(arg)
    if arg.class == Author
      @name == arg.name && @year_of_birth == arg.year_of_birth && @year_of_death == arg.year_of_death
    else
      false
    end
  end

end
