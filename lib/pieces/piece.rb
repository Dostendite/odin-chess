# piece class
# -- job is to act as a superclass and provide
# -- a basis for every piece in the game
class Piece
  attr_reader :color, :symbol
  attr_accessor :position

  # the position is represented as a
  # row / column pair, e.g.: [5, 2] (c4)
  def initialize(color, position)
    @color = color
    @position = position
  end

  def to_s
    black? ? @symbol[0] : @symbol[1]
  end

  def black?
    @color == "Black"
  end

  def out_of_bounds?(x, y)
    !(0..7).include?(x) || !(0..7).include?(y)
  end

  # when one is zero, the one doesn't work
  # but both work if they're negative
  def get_valid_squares(board)
    valid_squares = []
    
    unless @axes[:x].nil?
      valid_squares += calculate_squares(board, @axes[:x], 0)
      valid_squares += calculate_squares(board, -@axes[:x], 0)
    end
  
    unless @axes[:y].nil?
      valid_squares += calculate_squares(board, 0, @axes[:y])
      valid_squares += calculate_squares(board, 0, -@axes[:y])
    end
  
    unless @axes[:d].nil?
      valid_squares += calculate_squares(board, @axes[:d], @axes[:d])
      valid_squares += calculate_squares(board, @axes[:d], -@axes[:d])
      valid_squares += calculate_squares(board, -@axes[:d], @axes[:d])
      valid_squares += calculate_squares(board, -@axes[:d], -@axes[:d])
    end
    valid_squares
  end

  def calculate_squares(board, x_delta, y_delta)
    row, column = @position
    squares = []
  
    1.upto([x_delta.abs, y_delta.abs].max) do |range|

      unless x_delta.zero?
        x_delta = x_delta.negative? ? -range : range
      end

      unless y_delta.zero?
        y_delta = y_delta.negative? ? -range : range
      end

      break if out_of_bounds?(row + x_delta, column + y_delta)

      target_square = board[row + x_delta][column + y_delta]
      break if target_square.friendly?(@color)

      squares << target_square
      break if target_square.opposing?(@color)
    end
    squares
  end
end