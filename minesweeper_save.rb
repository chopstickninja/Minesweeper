require 'yaml'

class Field
  def initialize
    @field = Field.blank_field
    @lost_game = false
    @save = false
    add_bombs
    set_all_surr_bombs
  end

  def field(field)
    @field = field
  end

  def [](coord)
    x, y = coord
    @field[x][y]
  end

  def add_bombs
    bombs = Field.make_bombs
    bombs.each { |coord| self[coord].bomb = true }
  end

  def end_msg
    if @lost_game
      puts "You lost! Try again."
    elsif @save
      puts "Thanks for saving your game. Come back soon!"
    else
      puts "Congrats! You're the best. At winning Minesweeper. ...this time."
    end
  end

  def find_neighbors(coordinate)
    #given square, returns arr of neighbors
    shift = [[0,1],[0,-1],[1,0],[1,1],[1,-1],[-1,0],[-1,1],[-1,-1]]
    neighbors = shift.map {|(x, y)| [coordinate[0] + x, coordinate[1] + y]}

    neighbors.select {|coord| on_field?(coord)}
  end

  def game_over?
    return lost? || won?
  end

  def invalid_move_msg
    puts "Invalid move! Try again."
  end

  def lost?
    return true if @lost_game
    false
  end

  def make_move(action, coordinate)
    case action
    when "f"
      self[coordinate].flagged = !self[coordinate].flagged
    when "r"
      self[coordinate].revealed = true
      return nil if self[coordinate].surr_bombs > 0

      if self[coordinate].bomb == true
         @lost_game = true
      elsif self[coordinate].surr_bombs == 0
        neighbor_coordinates = find_neighbors(coordinate)

        neighbor_coordinates.each do |neighbor_coordinate|
          next if self[neighbor_coordinate].bomb
          next if self[neighbor_coordinate].revealed
          make_move("r", neighbor_coordinate)
        end
      end
    end
  end

  def play
    #display boad, welcome to game, prompt for move, explain how to move
    #get move, make move, check if game is over? if so, do something about it, otherwise get move
    until game_over? || @save
      self.show
      action, coordinate = Player.get_move
      if want_to_save?(action, coordinate)
        save_game
      elsif valid_move?(coordinate)
        make_move(action, coordinate)
      else
        invalid_move_msg
      end
    end

    self.show(all = true) unless @save #show vals for entire board incl bombs, etc
    end_msg
  end

  def save_game
    save = @field.to_yaml
    File.open('Minesweeper_save_file.txt', 'w') do |f|
      f.puts save
    end
    @save = true
  end

  def want_to_save?(action, coordinate)
    (action == "s") || (coordinate == "s")
  end

  def set_all_surr_bombs
    #for each bomb, changes square's surr_bombs
    @field.each_with_index do |row_squares, row|
      row_squares.each_with_index do |square, col|
        set_surr_bombs(square, [row, col])
      end
    end
  end

  def set_surr_bombs(square, coordinate)
    #find neighbors, count bombs, update square's surr_mines
    neighbors = find_neighbors(coordinate)

    count = 0
    neighbors.each do |neighbor|
      count += 1 if self[neighbor].bomb
    end
    square.surr_bombs = count
  end

  def show(all = false)
    #displays board
    display = "    0 1 2 3 4 5 6 7 8\n\n"

    @field.each_with_index do |row, idx|
      display << "#{idx}  "
      row.each do |square|
        display << square.display_value if !all
        display << square.display_value_all if all
      end
      display << "\n"
    end
    puts display
  end

  def valid_move?(coordinate)
    return false unless on_field?(coordinate)
    return false if self[coordinate].revealed
    true
  end

  def won?
    #goes through all squares to make sure there are no unrevealed/flagged squares
    @field.each do |row|
      row.each do |square|
        return false if !square.correctly_identified
      end
    end
    true
  end


  private
  def on_field?(coordinate)
    x, y = coordinate
    ((0 <= x) && (x <= 8)) && ((0 <= y) && (y <= 8))
  end

  def self.make_bombs
    bombs = []
    until bombs.uniq.length == 10
      bombs << [rand(9), rand(9)]
    end
    bombs
  end

  def self.blank_field
    field = []
    9.times do |idx|
      row = []
      9.times do |idx2|
        row << Square.new
      end
      field << row
    end
    field
  end

end

class Square
  attr_accessor :flagged, :revealed, :bomb, :surr_bombs

  def initialize
    flagged = false
    revealed = false
  end

  def correctly_identified
    return true if (!@bomb && @revealed)
    return true if (@bomb && @flagged)
    false
  end

  def display_value
    if flagged
      " F"
    elsif revealed
      surr_bombs == 0 ? "  " : " #{surr_bombs}"
    else
      " -"
    end
    #if revealed, dipslay surr_bombs (" " if this is 0). If flagged, F.
  end

  def display_value_all
    if flagged
      " F"
    elsif bomb
      " *"
    elsif revealed
      surr_bombs == 0 ? "  " : " #{surr_bombs}"
    else
      " -"
    end
  end

end

class Player
  def self.get_move
    puts ""
    puts "Where would you like to make a move? Enter location with 'row, column' coordinates (e.g. 1,2)"
    coordinate = gets.chomp.split(",")
    if coordinate[0] == "s"
      coordinate = "s"
    else
      coordinate = coordinate.map(&:lstrip).map(&:to_i)
    end
    puts "What would you like to do? Flag (f) or reveal (r)?"
    action = gets.chomp.downcase
    [action, coordinate]
  end
end

class Minesweeper
  def play
    initial_msg
    game = game_type
    if game
      game_yaml = File.read(game)
      old_field = YAML.load(game_yaml)
      Field.new.field(old_field).play
    else
      Field.new.play
    end
  end

  def initial_msg
    puts ""
    puts "Welcome to Minesweeper! Enter 's' at any point to save. Get ready for the time of your life..."
    puts ""
  end

  def game_type
    puts "Enter 'n' for new game or 'l' to load a game from disk."
    new_game = gets.downcase.chomp
    return false if new_game == "n"
    puts "Please type the file that has the saved game."
    game = gets.chomp
    game
  end
end

Minesweeper.new.play

#Field.new.play








