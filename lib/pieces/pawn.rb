require_relative "piece.rb"

# pawn class
# -- can move forwards two squares if it hasn't moved yet,
# -- move one forwards otherwise, attack one square forward
# -- diagonally, and punish another double-jumping pawn diagonally
# -- with en-passant. Can also promote to a queen, knight,
# -- or bishop when getting to the end of the board
class Pawn < Piece
  attr_accessor :moved

  def initialize(color, position)
    super(color, position)
    @symbol = "♟♙"
    @moved = false
  end

  def to_s
    black? ? @symbol[0] : @symbol[1]
  end

  def find_peaceful_moves(row, column, board)
    # check the square in front
    # if it's empty, add it
    peaceful_moves = []
    delta_one = color == "Black" ? -1 : 1
    delta_two = color == "Black" ? -2 : 2

    square_in_front = board[row + delta_one][column]

    if !square_in_front.nil?
      if square_in_front.empty?
        peaceful_moves << square_in_front
      end
    end

    if !@moved
      square_two_in_front = board[row + delta_two][column]
      if !square_in_front.nil?
        if square_two_in_front.empty?
          peaceful_moves << square_two_in_front
        end
      end
    end
    peaceful_moves
  end

  def find_attacking_moves(row, column, board)
    attacking_moves = []
    delta = color == "Black" ? -1 : 1

    diagonal_left_square = board[row + delta][column - 1]
    diagonal_right_square = board[row + delta][column + 1]
    
    if !diagonal_left_square.nil?
      if diagonal_left_square.opposing?(@color)
        attacking_moves << diagonal_left_square
      elsif diagonal_left_square.en_passant
        attacking_moves << diagonal_left_square
      end
    end

    if !diagonal_right_square.nil?
      if diagonal_right_square.opposing?(@color)
        attacking_moves << diagonal_right_square
      elsif diagonal_right_square.en_passant
        attacking_moves << diagonal_right_square
      end
    end

    attacking_moves
  end

  def get_valid_squares(board)
    valid_squares = []
    row, column = @position

    valid_squares += find_attacking_moves(row, column, board)
    valid_squares += find_peaceful_moves(row, column, board)
  end
end