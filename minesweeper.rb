class Field
  def initialize
    @field = Field.blank_field
    @lost_game = false
    add_bombs
    set_all_surr_bombs
  end

  def play
    #display boad, welcome to game, prompt for move, explain how to move
    #get move, make move, check if game is over? if so, do something about it, otherwise get move
    inital_msg

    until game_over?
      self.show
      action, coordinate = Player.get_move
      if valid_move?(coordinate)
        make_move(action)
      else
        puts "Invalid move! Try again."
      end
    end

    self.show_all #show vals for entire board incl bombs, etc

    end_msg

  end

  def initial_message
    puts "Welcome to Minesweeper! Get ready for the time of your life..."
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
    else
      puts "Congrats! You're the best. At winning Minesweeper. ...this time."
    end
  end

  def make_move(action)
    case action
    when "f"
      self[coordinate].flagged = !self[coordinate].flagged
    when "r"
      self[coordinate].revealed = true
      if self[coordinate].bomb == true
         @lost_game = true
      end
      if self[coordinate].surr_bombs == 0
        neighbor_coordinates = find_neighbors(coordinate)

        neighbor_coordinates.each do |neighbor_coordinate|
          next if self[neighbor_coordinate].bomb
          make_move("r", neighbor_coordinate)
        end
      end
    end
  end

  def valid_move?(coordinate)
    return false unless on_field?(coordinate)
    return false if self[coordinate].revealed
    true
  end

  def game_over?
    return lost? || won?
  end

  def lost?
    return true if @lost_game
    false
  end

  def won?
    #goes through all squares to make sure there are no unrevealed/flagged squares
    @field.each do |row|
      row_squares.each do |square|
        return false if !square.correctly_identified
      end
    end
    true
  end

  def show
    #displays board
    @field.dup.each { |row| puts row}
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

  def find_neighbors(coordinate)
    #given square, returns arr of neighbors
    shift = [[0,1],[0,-1],[1,0],[1,1],[1,-1],[-1,0],[-1,1],[-1,-1]]
    neighbors = shift.map {|(x, y)| [coordinate[0] + x, coordinate[1] + y]}

    neighbors.select {|coord| on_field?(coord)}
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

  def correctly_identified
    return true if (!@bomb && @revealed)
    return true if (@bomb && @flagged)
    false
  end
end

class Player
  def self.get_move
    puts "Where would you like to make a move? Enter coordinates (e.g. 1,2)"
    coordinate = gets.chomp.split(",")
    puts "What would you like to do? Flag (f) or reveal (r)?"
    action = gets.chomp
    [action, coordinate]
  end
end










