require_relative "square"
require_relative "serializer"

# board class
# -- job is to store the game squares
# -- and pieces within and offer functionality
# -- to the chess class
class Board
  include Serializer
  attr_reader :board

  def initialize
    @board = generate_board
  end

  def translate_coordinates(position)
    # "d4" -> [3][3]
    ord_base = 97
    pair_output = []
  
    row = (position[1].to_i) - 1
    column = (position[0].ord) - ord_base
  
    pair_output << row
    pair_output << column
  end
  
  def translate_coordinates_reverse(row, column)
    # [1][7] -> "h2"
    ord_base = 97
    algebraic_output = ""
  
    number = (row + 1).to_s
    letter = (column + ord_base).chr
  
    algebraic_output << letter
    algebraic_output << number
  end

  def generate_board(board = [])
    current_color = "black"
    (1..8).each do |number|
      sub_array = []
      ("a".."h").each do |letter|
        coordinate = "#{letter}#{number.to_s}"
        sub_array << Square.new(current_color, coordinate)
        unless letter == "h"
          current_color = current_color == "white" ? "black" : "white"
        end
      end
      board << sub_array
    end
    board
  end

  def move_piece(piece, target_position)
    target_row, target_column = translate_coordinates(target_position)
    remove_piece(piece.position)
    add_piece(target_row, target_column, piece)
  end

  def create_piece(type, color, position)
    case type
    when "Pawn"
      return Pawn.new(color, position)
    when "Knight"
      return Knight.new(color, position)
    when "Bishop"
      return Bishop.new(color, position)
    when "Rook"
      return Rook.new(color, position)
    when "Queen"
      return Queen.new(color, position)
    when "King"
      return King.new(color, position)
    end
  end

  def setup_pieces(piece_set)
  
  end

  def generate_piece_set
    piece_set = []
    
    8.times do
      pawn = create_piece("Pawn", "Black")
    end
    # Black player
    # Eight pawns -> a8 to h8
    # Two rooks -> a8 & h8
    # Two knights -> b8 & g8
    # Two bishops -> c8 & f8
    # Queen -> d8
    # King -> e8

    # Eight pawns -> a2 to h2
    # White player
    # Two rooks -> a1 & h1
    # Two knights -> b1 & g1
    # Two bishops -> c1 & f1
    # Queen -> d1
    # King -> e1
    # piece_set
  end

  def clear_squares(target_position)
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

  def legal_move?(piece_position, target_position)
    # return true if a move is legal
    # cases:
    # king moves into a place where it can get captured
    # 
  end

  # Optimize: Make it so that the player
  # can just input the move notation
  # https://en.wikipedia.org/wiki/Algebraic_notation_(chess)
  def disambiguate_move_pieces
    # when multiple pieces of the
    # same type can move to the same
    # square, return those pieces
    # to prompt the player for a choice
  end

  def can_promote?(pawn)
    if pawn.color == "white"
      pawn.position[1] == 7
    else
      pawn.position[1] == 0
    end
  end

  def add_piece(row, column, piece)
    target_square = @board[row][column]
    target_square.piece = piece
  end

  def remove_piece(row, column)
    target_square = @board[row][column]
    target_square.piece = nil
  end

  def promote_pawn(pawn)
    queen = create_piece("queen", pawn.color, pawn.position)
    @board.add_piece(pawn.position, queen)
  end

  def reset_board; end
  def save_board; end
  def load_board; end
end



