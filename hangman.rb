class Hangman

  attr_reader :known_letters

  def initialize(word_guesser, word_chooser)
    @word_guesser = word_guesser
    @word_chooser = word_chooser
    @word_chooser.choose_word
    p @known_letters = Array.new(@word_chooser.secret_word_length) {"_"}
    @guessed_letters = []
    @wrong_guesses_left = 6
    play
  end

  def render
    p "You have #{@wrong_guesses_left} left"
    p @known_letters.join(" ")
  end

  def play
    render
    while !over?
      guess = @word_guesser.guess_letter(@known_letters, @guessed_letters)
      @guessed_letters << guess
      letter_locations = @word_chooser.check_letter(guess)
      fill_word(letter_locations,guess)
      render
    end

  end

  def over?
    if !@known_letters.include?("_")
      puts "#{@word_guesser.name} wins!!!!"
      return true
    elsif @wrong_guesses_left == 0
      @word_chooser.wins
      return true
    end
  end


  def fill_word(locations, letter)
    p locations
    if locations == []
      @wrong_guesses_left -= 1
      puts "Yikes..., no #{letter}'s."
    else
      puts "Yahtzee!! There's a #{letter} at these locations: #{locations}"
      locations.each do |fill_this_index|
        @known_letters[fill_this_index] = letter
    end
  end


end
end

class Player

end

class HumanPlayer < Player

  attr_reader :secret_word_length, :name

  def initialize(name)
    @secret_word_length
    @name = name
  end

  def guess_letter(word_length, guessed_letters)
    print "Guess a letter: "
    guess = gets.chomp.downcase
  end

  def choose_word
    puts "ok... Think of a word in your head"
    puts "How many letters is your word?"
    @secret_word_length = gets.chomp.to_i
  end

  def check_letter(guessed_letter)
    puts "Are there any #{guessed_letter}'s in your word? (y/n)"
    confirmation = gets.chomp.downcase
    if confirmation == "y"
      puts "Where is the #{guessed_letter} in your word? (separate the numbers by a comma ex 1,5)"
      gets.chomp.split(",").map {|loc| loc.to_i}
    else
      []
    end
  end

  def wins
    puts "ok ok... you win. What was the word?"
    puts "OHHH! #{gets.chomp}! I should've known!"
  end

end

class ComputerPlayer < Player

  attr_reader :secret_word_length, :name

  def initialize(name)
    @name = name
    @dict = File.readlines("dictionary.txt").map {|word| word.chomp}
  end

  def choose_word
    p @secret_word = @dict.sample.chomp

    @secret_word_length = @secret_word.length
  end

  def check_letter(guessed_letter)
    letter_indexes = []
    if @secret_word.include?(guessed_letter)
      @secret_word.split("").each_with_index do |char, index|
        letter_indexes << index if char == guessed_letter
      end
    end
    letter_indexes
  end

  def wins
    puts "Yeah, ya blew it bro. The word was #{@secret_word}, duh"
  end

  def guess_letter(known_letters, guessed_letters)
    word_pool ||= @dict.select {|potential_word| potential_word.length == known_letters.length}
    word_so_far = known_letters
    word_so_far.each_with_index do |letter, index|
      if word_so_far[index] != "_"
        word_pool.delete_if { |word| word[index] != letter}
      end
    end
    p guessed_letters
    letter_pool = word_pool.join.split("").sort.uniq - guessed_letters #I know, I know, clunky. It takes every word and joins it into one massive "word", then splits it by letter, and finds every unique letter. Then it removes all previously guessed letters.
    p letter_pool
    letter_pool.sample
  end

end

human = HumanPlayer.new("Sam")
comp = ComputerPlayer.new("The Executor")
comp2 = ComputerPlayer.new("The Executor")
new_game = Hangman.new(comp, comp2)