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

  def allied_piece?(square)
    square.piece.color == @color
  end

  def get_valid_squares(board)
    valid_squares = []
    
    if !@axes[:x].nil?
      valid_squares += calculate_squares_x(board, @axes[:x])
      valid_squares += calculate_squares_x(board, -@axes[:x])
    end
  
    if !@axes[:y].nil?
      valid_squares += calculate_squares_y(board, @axes[:y])
      valid_squares += calculate_squares_y(board, -@axes[:y])
    end
  
    if !@axes[:d].nil?
      valid_squares += calculate_squares_d(board, @axes[:d], @axes[:d])
      valid_squares += calculate_squares_d(board, @axes[:d], -@axes[:d])
      valid_squares += calculate_squares_d(board, -@axes[:d], @axes[:d])
      valid_squares += calculate_squares_d(board, -@axes[:d], -@axes[:d])
    end
    valid_squares
  end

  def calculate_squares_x(board, x_delta)
    row, column = @position
    squares = []

    1.upto(x_delta.abs) do |delta|
      delta = -delta if x_delta.negative?

      break if out_of_bounds?(row + delta, column)
      
      target_square = board[row + delta][column]

      # make this into a predicate method or something
      if !target_square.empty?
        if allied_piece?(target_square)
          break
        else
          # opposing piece found
          squares << target_square
          break
        end
      end
      squares << target_square
    end
    squares
  end

  def calculate_squares_y(board, y_delta)
    row, column = @position
    squares = []

    1.upto(y_delta.abs) do |delta|
      delta = -delta if y_delta.negative?
    
      break if out_of_bounds?(row, column + delta)
      
      target_square = board[row][column + delta]

      if !target_square.empty?
        if allied_piece?(target_square)
          break
        else
          # opposing piece found
          squares << target_square
          break
        end
      end
      squares << target_square
    end
    squares
  end

  def calculate_squares_d(board, x_delta, y_delta)
    row, column = @position
    squares = []
    1.upto([x_delta, y_delta].max.abs) do |delta_amount|
      x_delta = x_delta.negative? ? -delta_amount : delta_amount
      y_delta = y_delta.negative? ? -delta_amount : delta_amount

      break if out_of_bounds?(row + x_delta.abs, column + y_delta.abs)

      target_square = board[row + x_delta][column + y_delta]
      # piece found
      if !target_square.empty?
        if allied_piece?(target_square)
          break
        else
          # opposing piece found
          squares << target_square
          break
        end
      end
      squares << target_square
    end
    squares
  end
end