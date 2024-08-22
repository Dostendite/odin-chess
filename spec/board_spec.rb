require_relative "../lib/board"

require_relative "../lib/pieces/piece.rb"
require_relative "../lib/pieces/pawn.rb"
require_relative "../lib/pieces/knight.rb"
require_relative "../lib/pieces/bishop.rb"
require_relative "../lib/pieces/rook.rb"
require_relative "../lib/pieces/queen.rb"
require_relative "../lib/pieces/king.rb"

RSpec.describe Board do
  describe "#generate_board" do
    subject(:chess_board) { described_class.new }

    it "generates a board with squares" do
      board = chess_board.generate_board
      expect(board[0][0]).to be_a Square
    end

    it "generates a board with 64 squares" do 
      board = chess_board.generate_board
      total_squares = []
      board.each { |row| row.each { |square| total_squares << square }}     
      expect(total_squares.length).to eq(64)
    end

    it "alternates between black and white squares" do
      board = chess_board.generate_board
      white_square = board[0][0]
      black_square = board[0][1]

      expect(white_square.color).to_not eq black_square.color
    end
  end

  describe "#swap_players" do
    subject(:chess_board) { described_class.new }

    it "returns 'White' if the current turn is black" do
      chess_board.swap_players
      black_turn = chess_board.instance_variable_get(:@current_turn)
      expect(black_turn).to eq("Black")
    end

    it "returns 'Black' if the current turn is white" do
      2.times do
        chess_board.swap_players
        chess_board.swap_players
      end

      white_turn = chess_board.instance_variable_get(:@current_turn)
      expect(white_turn).to eq("White")
    end
  end

  describe "#find_piece_class" do
    subject(:chess_board) { described_class.new }

    it "returns Knight when given 'n'" do
      piece_type = chess_board.find_piece_class('n')
      expect(piece_type).to eq(Knight)
    end

    it "returns Bishop when given 'k'" do
      piece_type = chess_board.find_piece_class('b')
      expect(piece_type).to eq(Bishop)
    end

    it "returns Rook when given 'k'" do
      piece_type = chess_board.find_piece_class('r')
      expect(piece_type).to eq(Rook)
    end

    it "returns Queen when given 'k'" do
      piece_type = chess_board.find_piece_class('q')
      expect(piece_type).to eq(Queen)
    end

    it "returns King when given 'k'" do
      piece_type = chess_board.find_piece_class('k')
      # why does .to be_a King not work?
      expect(piece_type).to eq(King)
    end
  end

  describe "#create_piece" do
    subject(:create_board) { described_class.new }

    it "returns a new Knight with (0, 5) as its position" do
      new_knight = create_board.create_piece(Knight, "Black", [0][5])
      expect(new_knight.position).to eq([0][5])
    end

    it "returns a new, white Pawn" do
      new_pawn = create_board.create_piece(Pawn, "White", [0][0])
      expect(new_pawn.color).to eq("White")
    end

    it "returns a new instance of Bishop" do
      new_bishop = create_board.create_piece(Bishop, "Black", [4][2])
      expect(new_bishop).to be_a Bishop
    end
  end
end