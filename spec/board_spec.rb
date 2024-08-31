require_relative "../lib/board"

require_relative "../lib/pieces/piece.rb"
require_relative "../lib/pieces/pawn.rb"
require_relative "../lib/pieces/knight.rb"
require_relative "../lib/pieces/bishop.rb"
require_relative "../lib/pieces/rook.rb"
require_relative "../lib/pieces/queen.rb"
require_relative "../lib/pieces/king.rb"

RSpec.describe Board do
  let(:chess_board) { described_class.new }
  let(:test_board) { chess_board.board }
  let(:white_rank) { 0 }
  let(:black_rank) { 7 }

  before(:each) do
    chess_board.board = chess_board.generate_board
  end

  describe "#generate_board" do
    it "generates a board with squares" do
      expect(test_board[0][0]).to be_a Square
    end

    it "generates a board with 64 squares" do 
      total_squares = []
      test_board.each { |row| row.each { |square| total_squares << square }}     
      expect(total_squares.length).to eq(64)
    end

    it "alternates between black and white squares" do
      white_square = test_board[0][0]
      black_square = test_board[0][1]

      expect(white_square.color).to_not eq black_square.color
    end
  end

  describe "#swap_players" do
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
    it "returns a new Knight with (0, 5) as its position" do
      new_knight = chess_board.create_piece(Knight, "Black", [0, 5])
      expect(new_knight.position).to eq([0, 5])
    end

    it "returns a new, white Pawn" do
      new_pawn = chess_board.create_piece(Pawn, "White", [0, 0])
      expect(new_pawn.color).to eq("White")
    end

    it "returns a new instance of Bishop" do
      new_bishop = chess_board.create_piece(Bishop, "Black", [4, 2])
      expect(new_bishop).to be_a Bishop
    end
  end

  describe "#add_piece" do
    it "adds a pawn to the square at [5][2]" do
      new_pawn = chess_board.create_piece(Pawn, "White", [0, 0])
      target_square = chess_board.board[5][2]
      chess_board.add_piece(new_pawn, [5, 2])
      expect(target_square.piece).to equal(new_pawn)
    end

    it "adds a queen to the square at [7][1]" do
      new_queen = chess_board.create_piece(Queen, "Black", [0, 0])
      target_square = chess_board.board[7][1]
      chess_board.add_piece(new_queen, [7, 1])
      expect(target_square.piece).to equal(new_queen)
    end
  end

  describe "#remove_piece" do
    before do
      rook_one = chess_board.create_piece(Rook, "White", [0, 0])
      rook_two = chess_board.create_piece(Rook, "Black", [0, 0])
      chess_board.add_piece(rook_one, [2, 2])
      chess_board.add_piece(rook_two, [2, 5])
    end

    it "removes a rook from [2][2]" do
      chess_board.remove_piece([2, 2])
      target_square = chess_board.board[2][2]
      expect(target_square.piece).to be_nil
    end

    it "removes a rook from [2][5]" do
      chess_board.remove_piece([2, 5])
      target_square = chess_board.board[2][5]
      expect(target_square.piece).to be_nil
    end
  end

  describe "#move_piece" do
    before do
      allow(chess_board).to receive(:check_en_passant)
    end

    it "removes the piece from the square where it was" do
      knight_to_move = chess_board.create_piece(Knight, "Black", [3, 3])
      chess_board.add_piece(knight_to_move, [3, 3])

      target_square = chess_board.board[3][3]
      chess_board.move_piece(knight_to_move, [5, 6])
      expect(target_square.piece).to be_nil
    end

    it "sets the piece's position to its new position" do
      pawn_to_move = chess_board.create_piece(Pawn, "White", [1, 4])
      chess_board.move_piece(pawn_to_move, [5, 5])
      new_pawn_position = pawn_to_move.position
      expect(new_pawn_position).to eq([5, 5])
    end

    it "adds the piece to the target position" do
      bishop_to_move = chess_board.create_piece(Bishop, "Black", [1, 2])
      chess_board.add_piece(bishop_to_move, [1, 2])
      chess_board.move_piece(bishop_to_move, [5, 5])
      target_square = chess_board.board[5][5]
      expect(target_square.piece).to equal(bishop_to_move)
    end

    it "checks for en passant" do
      pawn = chess_board.create_piece(Pawn, "White", [3, 5])
      chess_board.add_piece(pawn, [3, 5])
      expect(chess_board).to receive(:check_en_passant)
      chess_board.move_piece(pawn, [4, 5])
    end
  end

  describe "#give_check" do
    it "gives check to the White king" do
      king = King.new("White", [0, 4])
      chess_board.add_piece(king, king.position)
      chess_board.give_check("White")
      
      expect(king.in_check).to be true
    end

    it "gives check to the Black king" do
      king = King.new("Black", [7, 4])
      chess_board.add_piece(king, king.position)
      chess_board.give_check("Black")
      
      expect(king.in_check).to be true
    end
  end

  describe "#take_check" do
    it "takes check from the White king" do
      king = King.new("White", [0, 4])
      chess_board.add_piece(king, king.position)
      chess_board.give_check("White")
      chess_board.take_check("White")

      expect(king.in_check).to be false
    end

    it "takes check from the Black king" do
      king = King.new("Black", [7, 4])
      chess_board.add_piece(king, king.position)
      chess_board.give_check("Black")
      chess_board.take_check("Black")

      expect(king.in_check).to be false
    end
  end
  
  describe "#king_under_attack?" do
    it "returns true if the White king is under attack" do
      rook = Rook.new("Black", [5, 4])
      chess_board.add_piece(rook, rook.position)

      king = King.new("White", [0, 4])
      chess_board.add_piece(king, king.position)
  
      check_check = chess_board.king_under_attack?("White")
      expect(check_check).to be true
    end

    it "returns true if the Black king is under attack" do
      bishop = Bishop.new("White", [5, 2])
      chess_board.add_piece(bishop, bishop.position)

      king = King.new("Black", [7, 4])
      chess_board.add_piece(king, king.position)
  
      check_check = chess_board.king_under_attack?("Black")
      expect(check_check).to be true
    end

    it "returns false if the White king is protected" do
      rook = Rook.new("Black", [4, 7])
      chess_board.add_piece(rook, rook.position)

      pawn = Pawn.new("White", [4, 4])
      chess_board.add_piece(pawn, pawn.position)

      king = King.new("White", [4, 3])
      chess_board.add_piece(king, king.position)
  
      check_check = chess_board.king_under_attack?("White")
      expect(check_check).to be false
    end

    it "returns false if the Black king is protected" do
      rook_black = Rook.new("White", [6, 5])
      chess_board.add_piece(rook_black, rook_black.position)

      rook_white = Rook.new("Black", [3, 5])
      chess_board.add_piece(rook_white, rook_white.position)

      king = King.new("Black", [2, 5])
      chess_board.add_piece(king, king.position)
  
      check_check = chess_board.king_under_attack?("Black")
      expect(check_check).to be false
    end
  end

  describe "#find_all_pieces" do
    it "returns an array with all 16 White pieces" do
      chess_board.setup_pieces

      all_pieces = chess_board.find_all_pieces("White")

      expect(all_pieces.length).to eq(16)
    end

    it "returns an array with all 16 Black pieces" do
      chess_board.setup_pieces

      all_pieces = chess_board.find_all_pieces("Black")

      expect(all_pieces.length).to eq(16)
    end

    it "returns an array with 4 pieces when there are only 4 on the board" do
      4.times do |column|
        pawn = Pawn.new("White", [5, column])
        chess_board.add_piece(pawn, pawn.position)
      end

      all_pieces = chess_board.find_all_pieces("White")

      expect(all_pieces.length).to eq(4)
    end

    it "returns an empty array when there are no pieces on the board" do
      all_pieces = chess_board.find_all_pieces("White")

      expect(all_pieces).to be_empty
    end
  end

  describe "#find_piece_class" do
    it "returns Knight when given 'r'" do
      piece_class_check = chess_board.find_piece_class("n")
      expect(piece_class_check).to eq(Knight)
    end
    
    it "returns Bishop when given 'r'" do
      piece_class_check = chess_board.find_piece_class("b")
      expect(piece_class_check).to eq(Bishop)
    end

    it "returns Rook when given 'r'" do
      piece_class_check = chess_board.find_piece_class("r")
      expect(piece_class_check).to eq(Rook)
    end

    it "returns Queen when given 'q'" do
      piece_class_check = chess_board.find_piece_class("q")
      expect(piece_class_check).to eq(Queen)
    end

    it "returns King when given 'k'" do
      piece_class_check = chess_board.find_piece_class("k")
      expect(piece_class_check).to eq(King)
    end
  end

  describe "#promote_pawn" do
    it "promotes the Pawn to a Queen" do
      pawn = Pawn.new("White", [7, 6])
      chess_board.add_piece(pawn, pawn.position)
  
      target_square = test_board[7][6]
      chess_board.promote_pawn(pawn, Queen)

      expect(target_square.piece).to be_a Queen
    end

    it "promotes the Pawn to a Knight" do
      pawn = Pawn.new("White", [7, 6])
      chess_board.add_piece(pawn, pawn.position)
  
      target_square = test_board[7][6]
      chess_board.promote_pawn(pawn, Knight)

      expect(target_square.piece).to be_a Knight
    end

    it "promotes the Pawn to a Bishop" do
      pawn = Pawn.new("Black", [0, 6])
      chess_board.add_piece(pawn, pawn.position)
  
      target_square = test_board[0][6]
      chess_board.promote_pawn(pawn, Bishop)

      expect(target_square.piece).to be_a Bishop
    end

    it "promotes the Pawn to a Rook" do
      pawn = Pawn.new("Black", [0, 6])
      chess_board.add_piece(pawn, pawn.position)
  
      target_square = test_board[0][6]
      chess_board.promote_pawn(pawn, Rook)

      expect(target_square.piece).to be_a Rook
    end
  end

  describe "#setup_pawns" do
    it "places eight White pawns on the second rank" do
      chess_board.setup_pawns("White")
      white_pawns = []

      8.times do |file|
        target_position = test_board[1][file]
        if target_position.piece.instance_of?(Pawn)
          white_pawns << target_position.piece
        end
      end

      expect(white_pawns.length).to be(8)
    end

    it "places eight Black pawns on the seventh rank" do
      chess_board.setup_pawns("Black")
      black_pawns = []

      8.times do |file|
        target_position = test_board[6][file]
        if target_position.piece.instance_of?(Pawn)
          black_pawns << target_position.piece
        end
      end

      expect(black_pawns.length).to be(8)
    end
  end

  describe "#setup_knights" do
    it "places two white Knights on b1 and g1" do
      chess_board.setup_knights("White")

      knight_check = test_board[white_rank][1].piece.instance_of?(Knight) &&
                     test_board[white_rank][6].piece.instance_of?(Knight)

      expect(knight_check).to be true
    end

    it "places two black knights on b8 and g8" do
      chess_board.setup_knights("Black")
      
      knight_check = test_board[black_rank][1].piece.instance_of?(Knight) &&
                     test_board[black_rank][6].piece.instance_of?(Knight)

      expect(knight_check).to be true
    end
  end

  describe "#setup_bishops" do
    it "places two white bishops on c1 and f1" do
      chess_board.setup_bishops("White")
      
      bishop_check = test_board[white_rank][2].piece.instance_of?(Bishop) &&
                     test_board[white_rank][5].piece.instance_of?(Bishop)

      expect(bishop_check).to be true
    end

    it "places two black bishops on c8 and f8" do
      chess_board.setup_bishops("Black")
      
      bishop_check = test_board[black_rank][2].piece.instance_of?(Bishop) &&
                     test_board[black_rank][5].piece.instance_of?(Bishop)

      expect(bishop_check).to be true
    end
  end

  describe "#setup_rooks" do
    it "places two white rooks on a1 and h1" do
      chess_board.setup_rooks("White")
      
      rook_check = test_board[white_rank][0].piece.instance_of?(Rook) &&
                   test_board[white_rank][7].piece.instance_of?(Rook)

      expect(rook_check).to be true
    end

    it "places two black rooks on a8 and h8" do
      chess_board.setup_rooks("Black")

      rook_check = test_board[black_rank][0].piece.instance_of?(Rook) &&
                   test_board[black_rank][7].piece.instance_of?(Rook)

      expect(rook_check).to be true
    end
  end

  describe "#setup_royalty" do
    it "places a White King on e1 and a white Queen on d1" do
      chess_board.setup_royalty("White")

      royalty_check = test_board[white_rank][4].piece.instance_of?(King) &&
                      test_board[white_rank][3].piece.instance_of?(Queen)

      expect(royalty_check).to be true
    end

    it "places a Black King on e8 and a BlacGk Queen on d8" do
      chess_board.setup_royalty("Black")

      royalty_check = test_board[black_rank][4].piece.instance_of?(King) &&
                      test_board[black_rank][3].piece.instance_of?(Queen)

      expect(royalty_check).to be true
    end
  end

  describe "#setup_pieces" do
    before do
      allow(chess_board).to receive(:setup_pawns)
      allow(chess_board).to receive(:setup_knights)
      allow(chess_board).to receive(:setup_bishops)
      allow(chess_board).to receive(:setup_rooks)
      allow(chess_board).to receive(:setup_royalty)
    end

    after do
      chess_board.setup_pieces
    end

    it "calls setup_pawns" do
      expect(chess_board).to receive(:setup_pawns)
      
    end

    it "calls setup_knights" do
      expect(chess_board).to receive(:setup_knights)
    end

    it "calls setup_bishop" do
      expect(chess_board).to receive(:setup_bishops)
    end

    it "calls setup_rooks" do
      expect(chess_board).to receive(:setup_rooks)
    end

    it "calls setup_royalty" do
      expect(chess_board).to receive(:setup_royalty)
    end
  end

  describe "#castle_available?" do
    it "returns false when the White short castle squares are under threat" do
      king = King.new("White", [white_rank, 4])
      chess_board.add_piece(king, king.position)

      rook = Rook.new("White", [white_rank, 7])
      chess_board.add_piece(rook, rook.position)

      bishop = Bishop.new("Black", [2, 3])
      chess_board.add_piece(bishop, bishop.position)

      short_castle_check = chess_board.castle_available?("White", "short")
      expect(short_castle_check).to be false
    end

    it "returns false when the Black short castle squares are under threat" do
      king = King.new("Black", [black_rank, 4])
      chess_board.add_piece(king, king.position)
  
      rook = Rook.new("Black", [black_rank, 7])
      chess_board.add_piece(rook, rook.position)

      queen = Queen.new("White", [5, 6])
      chess_board.add_piece(queen, queen.position)

      short_castle_check = chess_board.castle_available?("Black", "short")
      expect(short_castle_check).to be false
    end

    it "returns false when the White long castle squares are under threat" do
      king = King.new("White", [white_rank, 4])
      chess_board.add_piece(king, king.position)
  
      rook = Rook.new("Black", [white_rank, 0])
      chess_board.add_piece(rook, rook.position)

      knight = Knight.new("White", [2, 2])
      chess_board.add_piece(knight, knight.position)

      short_castle_check = chess_board.castle_available?("White", "long")
      expect(short_castle_check).to be false
    end

    it "returns false when the Black long castle squares are under threat" do
      king = King.new("Black", [black_rank, 4])
      chess_board.add_piece(king, king.position)
  
      rook = Rook.new("Black", [black_rank, 0])
      chess_board.add_piece(rook, rook.position)

      rook = Rook.new("White", [4, 3])
      chess_board.add_piece(rook, rook.position)

      short_castle_check = chess_board.castle_available?("Black", "long")
      expect(short_castle_check).to be false
    end

    it "returns false when the White short castle squares are not under threat" do
      king = King.new("White", [white_rank, 4])
      chess_board.add_piece(king, king.position)
  
      rook = Rook.new("White", [white_rank, 7])
      chess_board.add_piece(rook, rook.position)

      short_castle_check = chess_board.castle_available?("White", "short")
      expect(short_castle_check).to be true
    end

    it "returns false when the Black short castle squares are not under threat" do
      king = King.new("Black", [black_rank, 4])
      chess_board.add_piece(king, king.position)
  
      rook = Rook.new("Black", [black_rank, 7])
      chess_board.add_piece(rook, rook.position)

      short_castle_check = chess_board.castle_available?("Black", "short")
      expect(short_castle_check).to be true
    end

    it "returns false when the White long castle squares are not under threat" do
      king = King.new("White", [white_rank, 4])
      chess_board.add_piece(king, king.position)
  
      rook = Rook.new("White", [white_rank, 0])
      chess_board.add_piece(rook, rook.position)

      short_castle_check = chess_board.castle_available?("White", "long")
      expect(short_castle_check).to be true
    end

    it "returns false when the Black long castle squares are not under threat" do
      king = King.new("Black", [black_rank, 4])
      chess_board.add_piece(king, king.position)
  
      rook = Rook.new("Black", [black_rank, 0])
      chess_board.add_piece(rook, rook.position)

      short_castle_check = chess_board.castle_available?("Black", "long")
      expect(short_castle_check).to be true
    end
  end
end