require_relative "piece.rb"

# knight class
# -- can jump over pieces and
# -- draw an L (2,1 || 1, 2) with its moves
class Knight < Piece
  attr_reader :knight_moves

  def initialize(color, position)
    super(color, position)
    @symbol = "♞♘"
    @knight_moves = generate_knight_moves
  end

  def generate_knight_moves
    recipe = [1, 2, -1, -2]
    moves = []

    recipe.each do |number|
      recipe.each do |other|
        next if number.abs == other.abs

        moves << [number, other]
      end
    end
    moves
  end

  def get_valid_squares(board)
    def find_knight_squares(board, piece)
      knight_squares = []
      row, column = @position
      @knight_moves.each do |knight_move|
        row_delta, column_delta = knight_move
        potential_position = (row + row_delta), (column + column_delta)
        next if out_of_bounds?(potential_position)
  
        knight_squares << board[row + row_delta][column + column_delta]
      end
      knight_squares
    end
  end
end