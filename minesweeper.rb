#Mine

class Field
  def initialize
    @field = Field.blank_field
    add_bombs
    set_all_surr_bombs
  end

  def [](coord)
    x, y = coord
    @field[x][y]
  end

  def add_bombs
    bombs = Field.make_bombs
    bombs.each { |coord| @field[coord].bomb = true }
  end

  def make_move(action, coordinate)
    #modifies the squares in @field
    #find the neightbors if the square has zero bombs, and call make move on all of them
    return false unless valid_move?(coordinate)

    case action
    when "f"
      @field[coordinate].flagged = !@field[coordinate].flagged
    when "r"
      @field[coordinate].revealed = true
      if @field[coordinate].bomb == true
        puts "bomb; break"
        break
      end
      if @field[coordinate].surr_bombs == 0
        neighbor_coordinates = find_neighbors(coordinate)

        neighbor_coordinates.each do |neighbor_coordinate|
          next if @field[neighbor_coordinate].bomb
          make_move("r", neighbor_coordinate)
        end
      end
    end
  end

  def valid_move?(coordinate)
    #not valid if square off of field, or revealed, or flagged???
    return false unless on_field?(coordinate)
    return false if @field[coordinate].revealed
    true
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
      count += 1 if @field[neighbor].bomb
    end
    square.surr_mines = count
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
    until bomb.uniq.length == 10
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








