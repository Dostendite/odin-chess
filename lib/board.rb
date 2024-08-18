require_relative "square"
require_relative "serializer"

require_relative "pieces/piece.rb"
require_relative "pieces/pawn.rb"
require_relative "pieces/knight.rb"
require_relative "pieces/bishop.rb"
require_relative "pieces/rook.rb"
require_relative "pieces/queen.rb"
require_relative "pieces/king.rb"

# lowercase letters for calculating ranks
ORD_BASE = 97

# board class
# -- job is to store the game squares
# -- and pieces within and offer functionality
# -- to the chess class
class Board
  include Serializer
  attr_accessor :board, :current_turn, :save_number

  def initialize(board = nil)
    @board = board
    @current_turn = "White"
    @new_game = true
    @save_number = nil
  end

  def load_board(save_number)
    @board = load_save(save_number)
    @save_number = Serializer.get_save_amount
    @new_game = false
  end

  def translate_coordinates(position)
    # "d4" -> [3][3]
    pair_output = []
  
    row = (position[1].to_i) - 1
    column = (position[0].ord) - ORD_BASE
  
    pair_output << row
    pair_output << column
  end
  
  def translate_coordinates_reverse(row, column)
    # [1][7] -> "h2"
    algebraic_output = ""
  
    number = (row + 1).to_s
    letter = (column + ORD_BASE).chr
  
    algebraic_output << letter
    algebraic_output << number
  end

  def create_new_board
    @board = generate_board
  end

  def generate_board(board = [])
    current_color = "Black"
    (1..8).each do |number|
      sub_array = []
      ("a".."h").each do |letter|
        coordinate = "#{letter}#{number.to_s}"
        sub_array << Square.new(current_color, coordinate)
        unless letter == "h"
          current_color = current_color == "White" ? "Black" : "White"
        end
      end
      board << sub_array
    end
    board
  end

  def move_piece(piece, target_position)
    target_position = translate_coordinates(target_position)
    remove_piece(piece.position)
    add_piece(target_position, piece)
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

  def find_color_file(color)
    if color == "Black"
      7
    else
      0
    end
  end

  def setup_pawns(color)
    if color == "Black"
      file = 6
    else
      file = 1
    end
    8.times do |rank|
      pawn = create_piece("Pawn", color, [file, rank])
      add_piece(pawn.position, pawn)
    end
  end

  def setup_rooks(color)
    file = find_color_file(color)

    rook_left = create_piece("Rook", color, [file, 0])
    rook_right = create_piece("Rook", color, [file, 7])
  
    add_piece(rook_left.position, rook_left)
    add_piece(rook_right.position, rook_right)
  end

  def setup_knights(color)
    file = find_color_file(color)

    knight_left = create_piece("Knight", color, [file, 1])
    knight_right = create_piece("Knight", color, [file, 6])

    add_piece(knight_left.position, knight_left)
    add_piece(knight_right.position, knight_right)
  end

  def setup_bishops(color)
    file = find_color_file(color)
    
    bishop_left = create_piece("Bishop", color, [file, 2])
    bishop_right = create_piece("Bishop", color, [file, 5])

    add_piece(bishop_left.position, bishop_left)
    add_piece(bishop_right.position, bishop_right)
  end

  def setup_royalty(color)
    file = find_color_file(color)

    queen = create_piece("Queen", color, [file, 3])
    king = create_piece("King", color, [file, 4])
    
    add_piece(queen.position, queen)
    add_piece(king.position, king)
  end

  def setup_pieces
    setup_pawns("White")
    setup_pawns("Black")
    setup_rooks("White")
    setup_rooks("Black")
    setup_knights("White")
    setup_knights("Black")
    setup_bishops("White")
    setup_bishops("Black")
    setup_royalty("White")
    setup_royalty("Black")
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

  # uses pain notation
  def move_out_of_bounds?(target_position)
    row, column = target_position

    !@board[row][column].instance_of?(Square)
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

  def add_piece(position, piece)
    row, column = position
    target_square = @board[row][column]
    target_square.piece = piece
  end

  def remove_piece(position)
    row, column = position
    target_square = @board[row][column]
    target_square.piece = nil
  end

  def promote_pawn(pawn)
    queen = create_piece("queen", pawn.color, pawn.position)
    @board.add_piece(pawn.position, queen)
  end

  def save_board
    if @new_game
      puts "New game, creating save..."
      create_save(@board)
      @save_number = Serializer.get_save_amount
      puts "Done! Created save #{save_number}."
      @new_game = false
    else
      update_save(@board, @save_number)
    end
  end
end



