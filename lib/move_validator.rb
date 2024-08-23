require "pry-byebug"

require_relative "display"

module MoveValidator
  include Display

  def find_pawn_below(board, target_position_pair, increment, current_turn)
    target_row, target_column = target_position_pair

    # could use this to refactor the huge methods below
    delta = current_turn == "Black" ? increment : -increment
    square_below = board[target_row + delta][target_column]
    validate_pawn_below(square_below, increment, current_turn)
  end

  def validate_pawn_below(square_below, increment, current_turn)
    if !square_below.empty? && square_below.piece.instance_of?(Pawn)
      if square_below.opposing?(current_turn)
        return nil
      elsif increment == 2 && square_below.piece.moved
        return nil
      end
      square_below.piece
    end
  end

  def find_attacking_pawns(board, target_position_pair, current_turn)
    attacking_pawns = []
    target_row, target_column = target_position_pair

    if current_turn == "Black"
      left_side = board[target_row + 1][target_column - 1]
      right_side = board[target_row + 1][target_column + 1]
    else
      left_side = board[target_row - 1][target_column - 1]
      right_side = board[target_row - 1][target_column + 1]
    end

    if !left_side.empty? && left_side.piece.instance_of?(Pawn) &&
      left_side.piece.color == current_turn
      attacking_pawns << left_side.piece
    end

    if !right_side.empty? && right_side.piece.instance_of?(Pawn) &&
      right_side.piece.color == current_turn
      attacking_pawns << right_side.piece
    end
    attacking_pawns
  end

  # RETURNS TRUE IF PIECE IS IN RANGE OF SQUARE
  def piece_in_range?(board, piece, squares, move)
    squares.any? { |square| square.coordinate == move[-2..] }
  end

  def find_available_pieces(board, piece_type, color)
    available_pieces = []
    board.each do |row|
      row.each do |square|
        next if square.empty?

        target_piece = square.piece
        if target_piece.color == color && target_piece.instance_of?(piece_type)
          available_pieces << square.piece
        end
      end 
    end
    available_pieces
  end

  def move_out_of_bounds?(target_position_pair)
    row, column = target_position_pair
    !(0..7).include?(row) || !(0..7).include?(column)
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