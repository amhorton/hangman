class Hangman

  attr_reader :code_length

  def play(guesser, checker, max_tries = 10)
    string = ""
    tries = 0
    @code_length = checker.secret_length
    guesser.code_length = @code_length

    code_length.times do
      string << "_"
    end

    until tries == max_tries
      tries += 1

      if string.include?("_")
        puts string
        puts "Secret word length: #{@code_length}"

        guess = guesser.make_guess
        puts "#{guesser.name}'s guess: #{guess}."
        checker.opponent_guess = guess

        feedback = checker.check
        guesser.opponent_feedback = feedback

        feedback.each do |pos|
          string[pos] = guess
        end
      end

      unless string.include?("_")
        puts "Guesser wins! Secret word was #{string}."
        return
      end
    end

    puts "Checker wins!"

  end


end

class ComputerPlayer

  attr_reader :secret_length, :name
  attr_accessor :opponent_guess, :opponent_feedback, :code_length

  def initialize(name)
    @name = name
    @dictionary = []

    File.foreach("dictionary.txt") do |line|
      @dictionary << line.chomp
    end

    @secret_word = @dictionary.sample
    @secret_length = @secret_word.length
    @last_guess = nil
    @already_guessed = []

  end



  def make_guess
    mode_hash = Hash.new(0)
    most_common = []

    @dictionary.delete_if{ |word| word.length != code_length}

    if @last_guess
      @dictionary = @dictionary.select do |word|
        valid = true

        @opponent_feedback.each do |pos|
          if word[pos] != @last_guess
            valid = false
          end
        end

        valid
      end
    end


    @dictionary.each do |word|
      word.each_char do |char|
        mode_hash[char] += 1
      end
    end

    @already_guessed.each do |letter|
      mode_hash[letter] = 0
    end

    max = mode_hash.values.max

    mode_hash.each do |letter, appearances|
      if appearances == max
        most_common << letter
      end
    end

    @last_guess = most_common.sample
    @already_guessed << @last_guess
    @last_guess
  end

  def check
    feedback = []

    if @secret_word.include?(opponent_guess)
      secret_word_arr = @secret_word.split("")

      secret_word_arr.each_with_index do |char, index|
        if char == opponent_guess
          feedback << index
        end
      end
    end

    feedback
  end


end

class HumanPlayer

  attr_reader :secret_length, :name
  attr_accessor :opponent_guess, :opponent_feedback, :code_length

  def initialize(name)
    @name = name
  end

  def make_guess
    puts "Which letter would you like to guess #{name}?"
    gets.chomp.downcase
  end

  def secret_length
    puts "How long is your word?"

    length = gets.chomp.to_i

    raise "PICK A NUMBER!" unless length.is_a?(Fixnum)

    length
  end

  def check
    feedback = []
    puts opponent_guess
    puts "Is this letter in your word? (y/n)"
    response = gets.chomp.downcase

    if response == "y"
      puts "Where in the word is this letter?"

      gets.chomp.delete(",").each_char do |char|
        feedback << char
      end

    end

    feedback.map { |num| num.to_i - 1}
  end

end

carl = HumanPlayer.new("Carl")
phil = HumanPlayer.new("Phil")
kikaider = ComputerPlayer.new("Kikaider")
nineteen = ComputerPlayer.new("Nineteen")
our_game = Hangman.new
our_game.play(nineteen, kikaider, 99)