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
      new_knight = create_board.create_piece(Knight, "Black", [0, 5])
      expect(new_knight.position).to eq([0, 5])
    end

    it "returns a new, white Pawn" do
      new_pawn = create_board.create_piece(Pawn, "White", [0, 0])
      expect(new_pawn.color).to eq("White")
    end

    it "returns a new instance of Bishop" do
      new_bishop = create_board.create_piece(Bishop, "Black", [4, 2])
      expect(new_bishop).to be_a Bishop
    end
  end

  describe "#add_piece" do
    subject(:add_board) { described_class.new }

    before do
      add_board.board = add_board.generate_board
    end

    it "adds a pawn to the square at [5][2]" do
      new_pawn = add_board.create_piece(Pawn, "White", [0, 0])
      target_square = add_board.board[5][2]
      add_board.add_piece(new_pawn, [5, 2])
      expect(target_square.piece).to equal(new_pawn)
    end

    it "adds a queen to the square at [7][1]" do
      new_queen = add_board.create_piece(Queen, "Black", [0, 0])
      target_square = add_board.board[7][1]
      add_board.add_piece(new_queen, [7, 1])
      expect(target_square.piece).to equal(new_queen)
    end
  end

  describe "#remove_piece" do
    subject(:remove_board) { described_class.new }

    before do
      remove_board.board = remove_board.generate_board
      rook_one = remove_board.create_piece(Rook, "White", [0, 0])
      rook_two = remove_board.create_piece(Rook, "Black", [0, 0])
      remove_board.add_piece(rook_one, [2, 2])
      remove_board.add_piece(rook_two, [2, 5])
    end

    it "removes a rook from [2][2]" do
      remove_board.remove_piece([2, 2])
      target_square = remove_board.board[2][2]
      expect(target_square.piece).to be_nil
    end

    it "removes a rook from [2][5]" do
      remove_board.remove_piece([2, 5])
      target_square = remove_board.board[2][5]
      expect(target_square.piece).to be_nil
    end
  end

  describe "#move_piece" do
    subject(:move_board) { described_class.new }

    before do
      move_board.board = move_board.generate_board
    end

    it "removes the piece from the square where it was" do
      knight_to_move = move_board.create_piece(Knight, "Black", [3, 3])
      move_board.add_piece(knight_to_move, [3, 3])

      target_square = move_board.board[3][3]
      move_board.move_piece(knight_to_move, [5, 6])
      expect(target_square.piece).to be_nil
    end

    it "sets the piece's position to its new position" do
      pawn_to_move = move_board.create_piece(Pawn, "White", [1, 4])
      move_board.move_piece(pawn_to_move, [5, 5])
      new_pawn_position = pawn_to_move.position
      expect(new_pawn_position).to eq([5, 5])
    end

    it "adds the piece to the target position" do
      bishop_to_move = move_board.create_piece(Bishop, "Black", [1, 2])
      move_board.add_piece(bishop_to_move, [1, 2])
      move_board.move_piece(bishop_to_move, [5, 5])
      target_square = move_board.board[5][5]
      expect(target_square.piece).to equal(bishop_to_move)
    end
  end
end