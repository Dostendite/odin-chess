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
    @board = nil
    @current_turn = "White"
    @new_game = true
    @save_number = nil
    @en_passant_pawn_square = nil # last pawn to do en passant (to remove)
    @piece_types = {"N" => Knight, "B" => Bishop, 
                    "R" => Rook, "Q" => Queen, "K" => King}
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

  def load_board(save_number)
    @board = load_save(save_number)
    @save_number = Serializer.get_save_amount
    @new_game = false
  end

  def move_piece(piece, target_position)
    target_position = translate_coordinates(target_position)
    remove_piece(piece.position)
    add_piece(target_position, piece)
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

  # Optimize: All setup methods
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

  def pieces_include?(piece_type)
    !@piece_types[piece_type.upcase].nil?
  end

  # should probably delete this method

  # def piece_available?(piece_type)
  #   piece_type = find_piece_class(piece_type.upcase)
  #   return false if piece_type.nil?

  #   @board.each do |row|
  #     row.any? do |square|
  #       next if square.empty?
  
  #       if square.piece.instance_of?(piece_type) && square.piece.color == @current_turn
  #         return true
  #       end
  #     end
  #   end
  #   false
  # end
  
  def swap_players
    if @current_turn == "White"
      @current_turn = "Black"
    else
      @current_turn = "White"
    end
  end

  def find_piece_class(piece_type)
    @piece_types[piece_type]
  end

  def can_promote?(pawn)
    if pawn.color == "white"
      pawn.position[1] == 7
    else
      pawn.position[1] == 0
    end
  end

  def move_out_of_bounds?(target_position)
    target_position = translate_coordinates(target_position)
    row, column = target_position
    !(0..7).include?(row) || !(0..7).include?(column)
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



