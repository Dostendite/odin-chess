require "pry-byebug"

require_relative "square"
require_relative "serializer"
require_relative "move_validator"

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
  include MoveValidator
  attr_accessor :board, :current_turn, :save_number, :new_game

  def initialize(board = nil)
    @board = nil
    @current_turn = "White"
    @new_game = true
    @save_number = nil
    @en_passant_pawn_square = nil # last pawn to do en passant (to remove)
    @piece_types = { "N" => Knight, "B" => Bishop, "R" => Rook, 
                    "Q" => Queen, "K" => King }
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

  def king_moved?(color)
    row = color == "White" ? 0 : 7
    
    if !@board[row][4].empty?
      @board[row][4].piece.moved == true
    end
  end

  # def move_piece(piece, target_position_pair)
  #   remove_piece(piece.position)
  #   piece.position = target_position_pair
  #   add_piece(piece, piece.position)
  # end

  def castle_short(current_turn = @current_turn)
    # binding.pry
    row = current_turn == "White" ? 0 : 7
    king = @board[row][4].piece
    rook = @board[row][7].piece

    king.moved = true
    rook.moved = true

    move_piece(king, [row, 6])
    move_piece(rook, [row, 5])
  end

  def castle_long(current_turn = @current_turn)
    # binding.pry
    row = current_turn == "White" ? 0 : 7
    king = @board[row][4].piece
    rook = @board[row][0].piece

    king.moved = true
    rook.moved = true

    move_piece(king, [row, 2])
    move_piece(rook, [row, 3])
  end

  def castle_available?(color = @current_turn, length)
    return false if king_moved?(color)
    
    row = color == "White" ? 0 : 7
    column = length == "short" ? 7 : 0

    rook_square = @board[row][column]
    if !rook_square.empty?
      return rook_square.piece.moved == false
    end
  end

  def valid_square?(piece, square)
    piece.get_valid_squares(@board).include?(square)
  end

  def move_piece(piece, target_position_pair)
    remove_piece(piece.position)
    piece.position = target_position_pair
    add_piece(piece, piece.position)
  end

  def add_piece(piece, position_pair)
    row, column = position_pair
    target_square = @board[row][column]
    target_square.piece = piece
  end

  def remove_piece(position_pair)
    row, column = position_pair
    @board[row][column].piece = nil
  end

  def promote_pawn(pawn)
    queen = create_piece("queen", pawn.color, pawn.position)
    @board.add_piece(pawn.position, queen)
  end

  def find_piece_class(piece_type)
    @piece_types[piece_type.upcase]
  end

  # Optimize: All setup methods
  def create_piece(type, color, position)
    type.new(color, position)
  end

  def find_color_file(color)
    color == "Black" ? 7 : 0
  end

  def setup_pawns(color)
    file = color == "Black" ? 6 : 1
    8.times do |rank|
      pawn = create_piece(Pawn, color, [file, rank])
      add_piece(pawn, pawn.position)
    end
  end

  def setup_rooks(color)
    file = find_color_file(color)
    rook_left = create_piece(Rook, color, [file, 0])
    rook_right = create_piece(Rook, color, [file, 7])
    add_piece(rook_left, rook_left.position)
    add_piece(rook_right, rook_right.position)
  end

  def setup_knights(color)
    file = find_color_file(color)
    knight_left = create_piece(Knight, color, [file, 1])
    knight_right = create_piece(Knight, color, [file, 6])
    add_piece(knight_left, knight_left.position)
    add_piece(knight_right, knight_right.position)
  end

  def setup_bishops(color)
    file = find_color_file(color)
    bishop_left = create_piece(Bishop, color, [file, 2])
    bishop_right = create_piece(Bishop, color, [file, 5])
    add_piece(bishop_left, bishop_left.position)
    add_piece(bishop_right, bishop_right.position)
  end

  def setup_royalty(color)
    file = find_color_file(color)
    queen = create_piece(Queen, color, [file, 3])
    king = create_piece(King, color, [file, 4])
    add_piece(queen, queen.position)
    add_piece(king, king.position)
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
  
  def swap_players
    if @current_turn == "White"
      @current_turn = "Black"
    elsif @current_turn == "Black"
      @current_turn = "White"
    end
  end

  def pieces_include?(piece_type)
    !@piece_types[piece_type.upcase].nil?
  end

  def can_promote?(pawn)
    if pawn.color == "White"
      pawn.position[1] == 7
    else
      pawn.position[1] == 0
    end
  end
end



