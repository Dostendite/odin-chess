require "pry-byebug"

require_relative "display"

module MoveValidator
  include Display

  def generate_pieces_in_range(board, piece_move)
    piece_type = board.find_piece_class(piece_move[0].upcase)
    target_pos_pair = translate_to_pair(piece_move[-2..])
    board.find_pieces_in_range(piece_type, target_pos_pair)
  end

  def generate_valid_squares(board, pieces_in_range, move_algebraic)
    target_pos_pair = translate_to_pair(move_algebraic)
    find_piece_squares(board, pieces_in_range, target_pos_pair)
  end

  def find_piece_squares(board, pieces, target_pair)
    piece_squares = []
    pieces.each do |piece|
      piece_squares += board.find_valid_squares(piece)
    end
    piece_squares
  end

  def translate_to_pair(position)
    # "d4" -> [3][3]
    pair_output = []

    row = (position[1].to_i) - 1
    column = (position[0].ord) - ORD_BASE

    pair_output << row
    pair_output << column
  end

  def translate_to_algebraic(row, column)
    # [1][7] -> "h2"
    algebraic_output = ""

    number = (row + 1).to_s
    letter = (column + ORD_BASE).chr

    algebraic_output << letter
    algebraic_output << number
  end
end

# --------- DUMP ---------

def run_simulation(condition)
  # condition could be to block
end

def squares_cleared?(target_position)
  # run for all pieces except
  # the knight, this method checks
  # if there's a piece obstructing
  # the desired path
end

def under_attack?(row, column)
  # return true if a square is under attack
  # scan all possible moves from all pieces
  # this might be the most important
  # predicate method, as it will
  # help find out what moves are legal
  # (especially in situations where the
  # king is under multiple threats, and
  # tactics like pins & skewers)
end