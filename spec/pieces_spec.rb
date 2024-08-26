require_relative "../lib/board"
require_relative "../lib/pieces/piece"

require_relative "../lib/pieces/pawn"
require_relative "../lib/pieces/knight"
require_relative "../lib/pieces/bishop"
require_relative "../lib/pieces/rook"
require_relative "../lib/pieces/queen"
require_relative "../lib/pieces/king"

# parent class of all the chess pieces
RSpec.describe Piece do
  subject(:piece) { described_class.new("White", [2, 2]) }

  describe "#black?" do
    it "returns true when the square color is 'Black'" do
      # is this a bad practice? do research
      # maybe I should use let instead
      black_piece = Piece.new("Black", [2, 4])
      black_check = black_piece.black?
      expect(black_check).to be true
    end
      
    it "returns false when the square color is 'White'" do
      white_piece = Piece.new("White", [4, 2])
      white_check = white_piece.black?
      expect(white_check).to be false
    end
  end

  describe "#out_of_bounds?" do
    it "returns true when x is out of bounds" do
      x = -1
      y = 5

      bounds_check = piece.out_of_bounds?(x, y)
      expect(bounds_check).to be true
    end

    it "returns true when y is out of bounds" do
      y = 8
      x = 0

      bounds_check = piece.out_of_bounds?(x, y)
      expect(bounds_check).to be true
    end

    it "returns true when both are out of bounds" do
      x = 15
      y = -5

      bounds_check = piece.out_of_bounds?(x, y)
      expect(bounds_check).to be true
    end

    it "returns false when both are in bounds" do
      x = 5
      y = 0

      bounds_check = piece.out_of_bounds?(x, y)
      expect(bounds_check).to be false
    end

    it "returns false when both are in bounds (II)" do
      y = 7
      x = 1

      bounds_check = piece.out_of_bounds?(x, y)
      expect(bounds_check).to be false
    end
  end
end

# tests for all the chess pieces

# board editor link used:
# https://lichess.org/editor/8/8/8/8/8/8/8/8_w_-_-_0_1?color=white

# they are written in this order:
# 1. valid move squares
# 2. blocked squares 
# 3. capture squares

RSpec.describe Pawn do
  describe "#get_valid_squares" do
    it "returns two squares ahead when the pawn hasn't moved" do
      # can't use a before block because the variables aren't
      # in scope, do more research
      chess_board = Board.new
      chess_board.board = chess_board.generate_board
      test_board = chess_board.board

      pawn = Pawn.new("White", [1, 4])
      valid_squares = pawn.get_valid_squares(test_board)

      expect(valid_squares.length).to be(2)
    end

    it "returns one square ahead when the pawn has moved" do
      chess_board = Board.new
      chess_board.board = chess_board.generate_board
      test_board = chess_board.board

      pawn = Pawn.new("White", [1, 4])
      pawn.instance_variable_set(:@moved, true)

      valid_squares = pawn.get_valid_squares(test_board)

      expect(valid_squares.length).to be(1)
    end

    it "returns no squares when a piece is one square ahead" do
      chess_board = Board.new
      chess_board.board = chess_board.generate_board
      test_board = chess_board.board

      opposing_piece = Pawn.new("White", [5, 4])
      chess_board.add_piece(opposing_piece, opposing_piece.position)

      pawn = Pawn.new("Black", [6, 4])
      valid_squares = pawn.get_valid_squares(test_board)

      expect(valid_squares).to be_empty
    end

    it "returns one square ahead when a piece is two squares ahead" do
      chess_board = Board.new
      chess_board.board = chess_board.generate_board
      test_board = chess_board.board

      opposing_piece = Pawn.new("White", [4, 4])
      chess_board.add_piece(opposing_piece, opposing_piece.position)

      pawn = Pawn.new("Black", [6, 4])
      valid_squares = pawn.get_valid_squares(test_board)

      expect(valid_squares.length).to be(1)
    end

    it "returns a diagonal move when a piece is one diagonal square ahead" do
      chess_board = Board.new
      chess_board.board = chess_board.generate_board
      test_board = chess_board.board

      opposing_piece = Pawn.new("White", [5, 5])
      chess_board.add_piece(opposing_piece, opposing_piece.position)

      pawn = Pawn.new("Black", [6, 4])
      valid_squares = pawn.get_valid_squares(test_board)

      # 2 peaceful moves + 1 attacking
      expect(valid_squares.length).to be(3)
    end

    it "returns two diagonal moves when two pieces are diagonal squares ahead" do
      chess_board = Board.new
      chess_board.board = chess_board.generate_board
      test_board = chess_board.board

      opposing_piece_left = Pawn.new("White", [5, 3])
      chess_board.add_piece(opposing_piece_left, opposing_piece_left.position)

      opposing_piece_right = Pawn.new("White", [5, 5])
      chess_board.add_piece(opposing_piece_right, opposing_piece_right.position)

      pawn = Pawn.new("Black", [6, 4])
      valid_squares = pawn.get_valid_squares(test_board)

      expect(valid_squares.length).to be(4)
    end
  end
end

RSpec.describe Bishop do
end

RSpec.describe Knight do
  
end

RSpec.describe Rook do
  
end

RSpec.describe Queen do
  
end

RSpec.describe King do
  
end