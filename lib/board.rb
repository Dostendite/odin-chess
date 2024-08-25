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
  attr_reader :piece_types
  attr_accessor :board, :current_turn, :save_number, :new_game

  def initialize(board = nil)
    @board = nil
    @current_turn = "White"
    @new_game = true
    @save_number = nil
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
    king = find_available_pieces(@board, King, color)[0]
    king.moved
  end

  def castle_short(current_turn = @current_turn)
    row = current_turn == "White" ? 0 : 7
    king = @board[row][4].piece
    rook = @board[row][7].piece

    king.moved = true
    rook.moved = true

    move_piece(king, [row, 6])
    move_piece(rook, [row, 5])
  end

  def castle_long(current_turn = @current_turn)
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

    opponent_color = color == "White" ? "Black" : "White"
    row = color == "White" ? 0 : 7
    column = length == "short" ? 7 : 0
    squares_to_check = []

    if length == "short"
      squares_to_check << @board[row][4]
      squares_to_check << @board[row][5]
      squares_to_check << @board[row][6]
    else
      squares_to_check << @board[row][2]
      squares_to_check << @board[row][3]
      squares_to_check << @board[row][4]
    end

    opponent_squares = find_all_move_squares(opponent_color)

    squares_under_attack = squares_to_check.any? do |square_to_check|
      opponent_squares.include?(square_to_check)
    end

    return false if squares_under_attack

    rook_square = @board[row][column]
    if !rook_square.empty?
      return rook_square.piece.moved == false
    end
  end

  def valid_square?(piece, square)
    piece.get_valid_squares(@board).include?(square)
  end

  def move_piece(piece, target_position_pair)
    check_en_passant(piece, target_position_pair) if piece.instance_of?(Pawn)
    remove_piece(piece.position)
    piece.position = target_position_pair
    add_piece(piece, piece.position)
  end

  def check_en_passant(piece, target_position_pair)
    piece_row = piece.position[0] # 2 or 7
    target_row, target_column = target_position_pair # 4 or 5
    difference = (target_row - piece_row).abs

    # marks en passant square as en passant
    if difference == 2
      if piece.color == "Black"
        @board[target_row + 1][target_column].en_passant_black = true
      else
        @board[target_row - 1][target_column].en_passant_white = true
      end
    end

    # removes en passant victim
    if piece.color == "Black"
      if @board[target_row][target_column].en_passant_white == true 
        @board[target_row + 1][target_column].piece = nil
      end
    else
      if @board[target_row][target_column].en_passant_black == true
        @board[target_row - 1][target_column].piece = nil
      end
    end
  end

  def remove_en_passant
    if @current_turn == "White"
      @board.each { |row| row.each { |square| square.en_passant_black = false } }
    else
      @board.each { |row| row.each { |square| square.en_passant_white = false } }
    end
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

  def promote_pawn(pawn, piece_type)
    row, column = pawn.position
    new_piece = create_piece(piece_type, pawn.color, pawn.position)
    @board[row][column].piece = new_piece
  end

  def give_check(color)
    king = find_available_pieces(@board, King, color)[0]
    king.in_check = true
  end

  def take_check(color)
    king = find_available_pieces(@board, King, color)[0]
    king.in_check = false
  end

  def find_all_move_squares(color)
    all_pieces = find_all_pieces(color)
    available_squares = []

    all_pieces.each do |piece|
      available_squares += piece.get_valid_squares(@board)
    end
    available_squares
  end

  def king_in_check?(king_color)
    opponent_color = king_color == "White" ? "Black" : "White"
    opponent_moves = find_all_move_squares(opponent_color)

    king = find_available_pieces(@board, King, king_color)[0]
    king_row, king_column = king.position
    king_square = @board[king_row][king_column]

    opponent_moves.include?(king_square)
  end

  def move_leads_to_check?(piece, target_pair)
    check_condition = false

    row, column = target_pair
    target_square = @board[row][column]
    original_position = piece.position

    if !target_square.empty?
      target_piece = target_square.piece.dup
    end

    move_piece(piece, target_pair)

    if king_in_check?(@current_turn)
      check_condition = true
    end

    # undo move
    move_piece(piece, original_position)

    if target_piece
      add_piece(target_piece, target_piece.position)
    end

    check_condition
  end

  def find_available_check_dodges(color)
    # every element inside contains the piece & move pair
    available_pieces_and_moves = []
    available_pieces = find_all_pieces(color)

    available_pieces.each do |piece|
      available_squares = piece.get_valid_squares(@board)

      available_squares.each do |square|
        original_piece_pos = piece.position
        
        target_pair = translate_to_pair(square.coordinate)

        if !square.empty?
          square_piece = square.piece.dup
        end

        move_piece(piece, target_pair)

        if !king_in_check?(color)
          available_pieces_and_moves << [piece, target_pair]
        end

        # undo move
        move_piece(piece, original_piece_pos)
        if !square_piece.nil?
          add_piece(square_piece, square_piece.position)
        end
      end
    end
    available_pieces_and_moves
  end 

  def find_all_pieces(color = nil)
    pieces = []
    board.each do |row|
      row.each do |square|
        if !square.empty?
          if !color.nil?
            pieces << square.piece if square.friendly?(color)
          else
            pieces << square.piece
          end
        end
      end
    end
    pieces
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



