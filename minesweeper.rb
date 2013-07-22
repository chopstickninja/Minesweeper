#Mine

class Field
  def initialize
    @field = Field.blank_field
    add_bombs
    set_all_surr_bombs
  end

  def add_bombs
    bombs = Field.make_bombs
    bombs.each { |(row, col)| @field[row][col].bomb = true }
  end

  def make_move
    #modifies the squares in @field
    #find the neightbors if the square has zero bombs, and call make move on all of them
  end

  def valid_move?(coordinate)
    #not valid if square off of field, or revealed, or flagged???
    x, y = coordinate
    return false unless on_field?(coordinate)
    return false if @field[x][y].revealed
    true
  end

  def won?
    #goes through all squares to make sure there are no unrevealed/flagged squares
    @field.each do |row|
      row_squares.each do |square|
        return false if
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
      x, y = neighbor
      count += 1 if @field[x][y].bomb
    end
    square.surr_mines = count
  end

  def find_neighbors(coordinate)
    #given square, returns arr of neighbors
    neighbors = []
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

  def unrevealed_bomb
    @bomb == true && @revealed == false
  end
end








