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

# they account for the move & capture squares and blockages

RSpec.describe Pawn do
  describe "#get_valid_squares" do
    let(:chess_board) { Board.new }

    before do
      chess_board.board = chess_board.generate_board
    end

    let(:test_board) { chess_board.board }

    it "returns two squares ahead when the pawn hasn't moved" do
      # can't use a before block because the variables aren't
      # in scope, do more research
      pawn = Pawn.new("White", [1, 4])
      valid_squares = pawn.get_valid_squares(test_board)

      expect(valid_squares.length).to be(2)
    end

    it "returns one square ahead when the pawn has moved" do
      pawn = Pawn.new("White", [1, 4])
      pawn.instance_variable_set(:@moved, true)

      valid_squares = pawn.get_valid_squares(test_board)

      expect(valid_squares.length).to be(1)
    end

    it "returns no squares when a piece is one square ahead" do
      opposing_piece = Pawn.new("White", [5, 4])
      chess_board.add_piece(opposing_piece, opposing_piece.position)

      pawn = Pawn.new("Black", [6, 4])
      valid_squares = pawn.get_valid_squares(test_board)

      expect(valid_squares).to be_empty
    end

    it "returns one square ahead when a piece is two squares ahead" do
      opposing_piece = Pawn.new("White", [4, 4])
      chess_board.add_piece(opposing_piece, opposing_piece.position)

      pawn = Pawn.new("Black", [6, 4])
      valid_squares = pawn.get_valid_squares(test_board)

      expect(valid_squares.length).to be(1)
    end

    it "returns a diagonal move when a piece is one diagonal square ahead" do
      opposing_piece = Pawn.new("White", [5, 5])
      chess_board.add_piece(opposing_piece, opposing_piece.position)

      pawn = Pawn.new("Black", [6, 4])
      valid_squares = pawn.get_valid_squares(test_board)

      # 2 peaceful moves + 1 attacking
      expect(valid_squares.length).to be(3)
    end

    it "returns two diagonal moves when two pieces are diagonal squares ahead" do
      opposing_piece_left = Pawn.new("White", [5, 3])
      chess_board.add_piece(opposing_piece_left, opposing_piece_left.position)

      opposing_piece_right = Pawn.new("White", [5, 5])
      chess_board.add_piece(opposing_piece_right, opposing_piece_right.position)

      pawn = Pawn.new("Black", [6, 4])
      valid_squares = pawn.get_valid_squares(test_board)

      # 2 peaceful moves + 2 attacking
      expect(valid_squares.length).to be(4)
    end
  end
end

RSpec.describe Bishop do
  describe "#get_valid_squares" do
    let(:chess_board) { Board.new }

    before do
      chess_board.board = chess_board.generate_board
    end

    let(:test_board) { chess_board.board }

    it "returns 13 squares when alone in e4" do
      bishop = Bishop.new("White", [3, 4])
      valid_squares = bishop.get_valid_squares(test_board)

      expect(valid_squares.length).to be(13)
    end

    it "returns 9 squares when alone in g7" do
      bishop = Bishop.new("White", [6, 6])
      valid_squares = bishop.get_valid_squares(test_board)

      expect(valid_squares.length).to be(9)
    end

    it "returns 10 squares when alone with a horse in d4" do
      # gotta love Bojack
      horse = Knight.new("White", [4, 4])
      chess_board.add_piece(horse, horse.position)

      bishop = Bishop.new("Black", [3, 3])
      valid_squares = bishop.get_valid_squares(test_board)

      # 9 valid moves + 1 capture move
      expect(valid_squares.length).to be(10)
    end

    it "returns no squares when diagonally surrounded on g7 by friendly pieces" do
      pawn_one = Pawn.new("Black", [7, 5])
      chess_board.add_piece(pawn_one, pawn_one.position)

      pawn_two = Pawn.new("Black", [5, 5])
      chess_board.add_piece(pawn_two, pawn_two.position)

      pawn_three = Pawn.new("Black", [7, 7])
      chess_board.add_piece(pawn_three, pawn_three.position)
  
      pawn_four = Pawn.new("Black", [5, 7])
      chess_board.add_piece(pawn_four, pawn_four.position)

      bishop = Bishop.new("Black", [6, 6])
      valid_squares = bishop.get_valid_squares(test_board)

      expect(valid_squares.length).to be(0)
    end

    it "returns 7 squares when on c5 and in range of two enemy pieces" do
      pawn = Pawn.new("White", [5, 3])
      chess_board.add_piece(pawn, pawn.position)
  
      knight = Pawn.new("White", [2, 4])
      chess_board.add_piece(knight, knight.position)

      bishop = Bishop.new("Black", [4, 2])
      valid_squares = bishop.get_valid_squares(test_board)

      expect(valid_squares.length).to be(7)
    end
  end
end

RSpec.describe Knight do
  describe "#get_valid_squares" do
    let(:chess_board) { Board.new }

    before do
      chess_board.board = chess_board.generate_board
    end

    let(:test_board) { chess_board.board }

    it "returns 8 squares when on d3" do
      knight = Knight.new("Black", [4, 4])
      valid_squares = knight.get_valid_squares(test_board)

      expect(valid_squares.length).to be(8)
    end

    it "returns 2 squares when on a8" do
      knight = Knight.new("White", [7, 0])
      valid_squares = knight.get_valid_squares(test_board)

      expect(valid_squares.length).to be(2)
    end

    it "returns 6 squares when on d5 and with friendly pawns" do
      pawn_one = Pawn.new("Black", [6, 4])
      chess_board.add_piece(pawn_one, pawn_one.position)
      pawn_two = Pawn.new("Black", [5, 5])
      chess_board.add_piece(pawn_two, pawn_two.position)

      knight = Knight.new("Black", [4, 3])
      valid_squares = knight.get_valid_squares(test_board)

      expect(valid_squares.length).to be(6)
    end

    it "returns 8 squares when surrounded" do
      pawn_one = Pawn.new("White", [6, 3])
      chess_board.add_piece(pawn_one, pawn_one.position)
      pawn_two = Pawn.new("White", [6, 5])
      chess_board.add_piece(pawn_two, pawn_two.position)
      pawn_three = Pawn.new("White", [5, 2])
      chess_board.add_piece(pawn_three, pawn_three.position)
      pawn_four = Pawn.new("White", [5, 6])
      chess_board.add_piece(pawn_four, pawn_four.position)
      pawn_five = Pawn.new("White", [3, 2])
      chess_board.add_piece(pawn_five, pawn_five.position)
      pawn_six = Pawn.new("White", [3, 6])
      chess_board.add_piece(pawn_six, pawn_six.position)
      pawn_seven = Pawn.new("White", [2, 3])
      chess_board.add_piece(pawn_seven, pawn_seven.position)
      pawn_eight = Pawn.new("White", [2, 5])
      chess_board.add_piece(pawn_eight, pawn_eight.position)

      knight = Knight.new("Black", [4, 4])
      valid_squares = knight.get_valid_squares(test_board)

      expect(valid_squares.length).to be(8)
    end
  end
end

RSpec.describe Rook do
  describe "#get_valid_squares" do
    let(:chess_board) { Board.new }

    before do
      chess_board.board = chess_board.generate_board
    end

    let(:test_board) { chess_board.board }
    
    it "returns 14 squares when alone on the a1" do
      rook = Rook.new("White", [0, 0])
      valid_squares = rook.get_valid_squares(test_board)

      expect(valid_squares.length).to be(14)
    end

    it "returns 14 squares when alone on c6" do
      rook = Rook.new("White", [5, 2])
      valid_squares = rook.get_valid_squares(test_board)

      expect(valid_squares.length).to be(14)
    end

    it "returns 9 squares when in front of an opposing pawn on g7" do
      pawn = Pawn.new("White", [5, 6])
      chess_board.add_piece(pawn, pawn.position)
      
      rook = Rook.new("Black", [6, 6])
      valid_squares = rook.get_valid_squares(test_board)

      # 8 valid move + 1 capture move
      expect(valid_squares.length).to be(9)
    end
  end
end

RSpec.describe Queen do
  let(:chess_board) { Board.new }

  before do
    chess_board.board = chess_board.generate_board
  end

  let(:test_board) { chess_board.board }

  
end

RSpec.describe King do
  
end