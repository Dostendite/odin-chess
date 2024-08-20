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
  attr_accessor :board, :current_turn, :save_number

  def initialize(board = nil)
    @board = nil
    @current_turn = "White"
    @new_game = true
    @save_number = nil
    @en_passant_pawn_square = nil # last pawn to do en passant (to remove)
    @piece_types = {"N" => Knight, "B" => Bishop, "R" => Rook, 
                    "Q" => Queen, "K" => King}
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

  # METHODS THAT WORK WITH MOVE VALIDATOR
  require "pry-byebug"

  # return a piece that is in range of that move
  def find_pieces_in_range(piece_type, target_position_pair)
    pieces_in_range = []
    available_pieces = find_available_pieces(piece_type)
    
    available_pieces.each do |piece|
      squares_in_range = find_squares_in_range(piece)
      squares_in_range.each do |square|
        square_position_pair = translate_to_pair(square.coordinate)
        if square_position_pair == target_position_pair
          pieces_in_range << piece
          break
        end
      end
    end
    pieces_in_range
  end

  def find_available_pieces(piece_type, color = @current_turn)
    available_pieces = []
    @board.each do |row|
      row.each do |square|
        next if square.empty?

        if square.piece.color == color && square.piece.instance_of?(piece_type)
          available_pieces << square.piece
        end
      end
    end
    available_pieces
  end

  def find_squares_in_range(piece)
    squares_in_range = []
    if piece.instance_of?(Knight)
      squares_in_range += find_knight_squares(piece)
    else
      squares_in_range += find_horizontal_squares(piece)
      squares_in_range += find_vertical_squares(piece)
      squares_in_range += find_diagonal_squares(piece)
    end
    squares_in_range
  end

  require "pry-byebug"

  def find_knight_squares(piece)
    # binding.pry
    knight_squares = []
    knight_row, knight_column = piece.position
    piece.knight_moves.each do |knight_move|
      row_delta, column_delta = knight_move
      potential_position = [knight_row + row_delta, knight_column + column_delta]
      next if move_out_of_bounds?(potential_position)

      knight_squares << @board[knight_row + row_delta][knight_column + column_delta]
    end
    knight_squares
  end

  def find_horizontal_squares(piece)
    return [] if piece.horizontal_range == 0
  
    horizontal_squares = []
    piece_row, piece_column = piece.position
    (1..piece.horizontal_range).each do |column_delta|
      next if move_out_of_bounds?([piece_row, piece_column + column_delta])
      
      horizontal_squares << @board[piece_row][piece_column + column_delta]
    end

    (1..piece.horizontal_range).each do |column_delta|
      next if move_out_of_bounds?([piece_row, piece_column - column_delta]) 
      
      horizontal_squares << @board[piece_row][piece_column - column_delta]
    end
    horizontal_squares
  end

  def find_vertical_squares(piece)
    return [] if piece.vertical_forward_range == 0
    return [] if piece.vertical_backward_range == 0

    vertical_squares = []
    piece_row, piece_column = piece.position
    (1..piece.vertical_forward_range).each do |row_delta|
      next if move_out_of_bounds?([piece_row + row_delta, piece_column])

      forward_square = @board[piece_row + row_delta][piece_column]
      vertical_squares << forward_square
    end

    (1..piece.vertical_backward_range).each do |row_delta|
      next if move_out_of_bounds?([piece_row - row_delta, piece_column])

      backward_square = @board[piece_row - row_delta][piece_column]
      vertical_squares << backward_square
    end
    vertical_squares
  end

  def find_diagonal_squares(piece)
    return [] if piece.diagonal_forward_range == 0
    return [] if piece.diagonal_backward_range == 0

    diagonal_squares = []
    diagonal_squares += find_diagonal_forward_squares(piece)
    diagonal_squares += find_diagonal_backward_squares(piece)
  end

  def find_diagonal_forward_squares(piece)
    return if piece.diagonal_forward_range == 0

    diagonal_forward_squares = []
    piece_row, piece_column = piece.position
    (1..piece.diagonal_forward_range).each do |delta|
      next if move_out_of_bounds?([piece_row + delta, piece_column + delta])

      diagonal_forward_squares << @board[piece_row + delta][piece_column + delta]
    end

    (1..piece.diagonal_forward_range).each do |delta|
      next if move_out_of_bounds?([piece_row + delta, piece_column - delta])

      diagonal_forward_squares << @board[piece_row + delta][piece_column - delta]
    end
    diagonal_forward_squares
  end

  def find_diagonal_backward_squares(piece)
    return if piece.diagonal_backward_range == 0

    diagonal_backward_squares = []
    piece_row, piece_column = piece.position
    (1..piece.diagonal_backward_range).each do |delta|
      next if move_out_of_bounds?([piece_row - delta, piece_column + delta])

      diagonal_backward_squares << @board[piece_row - delta][piece_column + delta]
    end

    (1..piece.diagonal_backward_range).each do |delta|
      next if move_out_of_bounds?([piece_row - delta, piece_column - delta])

      diagonal_backward_squares << @board[piece_row - delta][piece_column - delta]
    end
    diagonal_backward_squares
  end

  def load_board(save_number)
    @board = load_save(save_number)
    @save_number = Serializer.get_save_amount
    @new_game = false
  end

  def move_piece(piece, target_position_pair)
    remove_piece(piece.position)
    piece.position = target_position_pair
    add_piece(piece.position, piece)
  end

  def add_piece(position_pair, piece)
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
    @piece_types[piece_type]
  end

  # Optimize: All setup methods
  def create_piece(type, color, position)
    return type.new(color, position)
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
      pawn = create_piece(Pawn, color, [file, rank])
      add_piece(pawn.position, pawn)
    end
  end

  def setup_rooks(color)
    file = find_color_file(color)
    rook_left = create_piece(Rook, color, [file, 0])
    rook_right = create_piece(Rook, color, [file, 7])
    add_piece(rook_left.position, rook_left)
    add_piece(rook_right.position, rook_right)
  end

  def setup_knights(color)
    file = find_color_file(color)
    knight_left = create_piece(Knight, color, [file, 1])
    knight_right = create_piece(Knight, color, [file, 6])
    add_piece(knight_left.position, knight_left)
    add_piece(knight_right.position, knight_right)
  end

  def setup_bishops(color)
    file = find_color_file(color)
    bishop_left = create_piece(Bishop, color, [file, 2])
    bishop_right = create_piece(Bishop, color, [file, 5])
    add_piece(bishop_left.position, bishop_left)
    add_piece(bishop_right.position, bishop_right)
  end

  def setup_royalty(color)
    file = find_color_file(color)
    queen = create_piece(Queen, color, [file, 3])
    king = create_piece(King, color, [file, 4])
    add_piece(queen.position, queen)
    add_piece(king.position, king)
  end

  def setup_pieces
    # setup_pawns("White")
    # setup_pawns("Black")
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
    else
      @current_turn = "White"
    end
  end

  def pieces_include?(piece_type)
    !@piece_types[piece_type.upcase].nil?
  end

  def can_promote?(pawn)
    if pawn.color == "white"
      pawn.position[1] == 7
    else
      pawn.position[1] == 0
    end
  end

  def move_out_of_bounds?(target_position_pair)
    row, column = target_position_pair
    !(0..7).include?(row) || !(0..7).include?(column)
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



