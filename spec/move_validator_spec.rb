require_relative "../lib/board"
require_relative "../lib/move_validator"

require_relative "../lib/pieces/piece.rb"
require_relative "../lib/pieces/pawn.rb"
require_relative "../lib/pieces/knight.rb"
require_relative "../lib/pieces/bishop.rb"
require_relative "../lib/pieces/rook.rb"
require_relative "../lib/pieces/queen.rb"
require_relative "../lib/pieces/king.rb"

RSpec.describe MoveValidator do
  let(:dummy_class) { Class.new { extend MoveValidator} }

  # find_available_pieces(board, piece_type, color)
  
  describe "#find_available_pieces" do
    let(:chess_board) { Board.new }
    let(:test_board) { chess_board.board }

    before do
      chess_board.board = chess_board.generate_board
    end

    it "returns two knights when in the starting position" do
      chess_board.setup_pieces
      pieces = dummy_class.find_available_pieces(test_board, Knight, "White")

      piece_test = pieces[0].instance_of?(Knight) && 
                   pieces[1].instance_of?(Knight)

      expect(piece_test).to be true
    end

    it "returns two bishops when in the starting position" do
      chess_board.setup_pieces
      pieces = dummy_class.find_available_pieces(test_board, Bishop, "White")

      piece_test = pieces[0].instance_of?(Bishop) && 
                   pieces[1].instance_of?(Bishop)

      expect(piece_test).to be true
    end

    it "returns eight pawns in the starting position" do
      chess_board.setup_pieces
      pieces = dummy_class.find_available_pieces(test_board, Pawn, "White")

      piece_test = pieces.all? { |piece| piece.instance_of?(Pawn) }
      expect(piece_test).to be true
    end

    it "returns three queens when alone together on the board" do
      3.times do |rank|
        queen = Queen.new("Black", [5, rank])
        chess_board.add_piece(queen, queen.position)
      end

      pieces = dummy_class.find_available_pieces(test_board, Queen, "Black")

      piece_test = pieces.all? { |piece| piece.instance_of?(Queen) }
      expect(piece_test).to be true
    end
  
    it "returns a Rook when alone on the board" do
      rook = Rook.new("White", [5, 4])
      chess_board.add_piece(rook, rook.position)

      pieces = dummy_class.find_available_pieces(test_board, Rook, "White")
      expect(pieces[0]).to be_a Rook
    end

    it "returns a King when alone on the board" do
      king = King.new("White", [4, 4])
      chess_board.add_piece(king, king.position)

      pieces = dummy_class.find_available_pieces(test_board, King, "White")
      expect(pieces[0]).to be_a King
    end
  end

  describe "#move_out_of_bounds?" do
    it "returns false when given [5, 7]" do
      target_pair = [5, 7]
      bounds_test = dummy_class.move_out_of_bounds?(target_pair)
      expect(bounds_test).to be false
    end

    it "returns false when given [3, 2]" do
      target_pair = [3, 2]
      bounds_test = dummy_class.move_out_of_bounds?(target_pair)
      expect(bounds_test).to be false
    end

    it "returns true when given [7, 8]" do
      target_pair = [7, 8]
      bounds_test = dummy_class.move_out_of_bounds?(target_pair)
      expect(bounds_test).to be true
    end

    it "returns true when inside [-1, 5]" do
      target_pair = [-1, 5]
      bounds_test = dummy_class.move_out_of_bounds?(target_pair)
      expect(bounds_test).to be true
    end
  end

  describe "#translate_to_pair" do
    it "returns [4, 5] when given f5" do
      algebraic_input = "f5"

      pair_output = dummy_class.translate_to_pair(algebraic_input)
      expect(pair_output).to eq([4, 5])
    end

    it "returns [6, 2] when given c7" do
      algebraic_input = "c7"

      pair_output = dummy_class.translate_to_pair(algebraic_input)
      expect(pair_output).to eq([6, 2])
    end

    it "returns [3, 7] when given h4" do
      algebraic_input = "h4"

      pair_output = dummy_class.translate_to_pair(algebraic_input)
      expect(pair_output).to eq([3, 7])
    end
  end

  describe "#translate_to_algebraic" do
    it "returns d2 when given [1, 3]" do
      algebraic_output = dummy_class.translate_to_algebraic(1, 3)
      expect(algebraic_output).to eq("d2")
    end

    it "returns g4 when given [3, 6]" do
      algebraic_output = dummy_class.translate_to_algebraic(3, 6)
      expect(algebraic_output).to eq("g4")
    end

    it "returns h8 when given [7, 7]" do
      algebraic_output = dummy_class.translate_to_algebraic(7, 7)
      expect(algebraic_output).to eq("h8")
    end
  end
end