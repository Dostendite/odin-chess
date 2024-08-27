require "pry-byebug"

require_relative "../lib/board"
require_relative "../lib/chess"
require_relative "../lib/square"
require_relative "../lib/display"
require_relative "../lib/serializer"
require_relative "../lib/move_validator"

require_relative "../lib/pieces/piece.rb"
require_relative "../lib/pieces/pawn.rb"
require_relative "../lib/pieces/knight.rb"
require_relative "../lib/pieces/bishop.rb"
require_relative "../lib/pieces/rook.rb"
require_relative "../lib/pieces/queen.rb"
require_relative "../lib/pieces/king.rb"

# use bin/rspec to run rspec
RSpec.describe Chess do
  let(:chess_game) { described_class.new }
  
  before(:each) do
    new_board = Board.new
    new_board.board = new_board.generate_board
    chess_game.instance_variable_set(:@chess_board, new_board)
  end

  let(:chess_board) { chess_game.instance_variable_get(:@chess_board) }
  let(:test_board) { chess_board.board }
  
  describe "#play_chess" do
    before do
      allow(chess_game).to receive(:introduce_player)
      allow(chess_game).to receive(:display_main_menu_reminder)
      allow(chess_game).to receive(:play_game)
    end

    it "introduces the player" do
      expect(chess_game).to receive(:introduce_player)
      chess_game.play_chess
    end

    it "shows the main menu reminder" do
      expect(chess_game).to receive(:display_main_menu_reminder)
      chess_game.play_chess
    end

    it "plays the game" do
      expect(chess_game).to receive(:play_game)
      chess_game.play_chess
    end
  end

  describe "#introduce_player" do
    before do
      allow(Serializer).to receive(:update_save_numbers)
      allow(chess_game).to receive(:display_introduction)
    end

    it "updates the serializer save numbers" do
      expect(Serializer).to receive(:update_save_numbers)
      chess_game.introduce_player
    end

    it "displays the introduction" do
      expect(chess_game).to receive(:display_introduction)
      chess_game.introduce_player
    end
  end

  describe "#make_move" do
    before do
      chess_game.start_new_game
      allow_any_instance_of(Board).to receive(:move_piece)
    end

    it "tells the chess board to move a piece" do
      expect(chess_board).to receive(:move_piece)
      chess_game.make_move("piece", "position")
    end
  end

  describe "#validate_move" do
    it "returns nil when the move length is below 2" do
      invalid_move = "c"
      
      validated_move = chess_game.validate_move(invalid_move)
      expect(validated_move).to be nil
    end

    it "returns nil when the move length is above 3" do
      invalid_move = "knight to ef four"
      
      validated_move = chess_game.validate_move(invalid_move)
      expect(validated_move).to be nil
    end

    it "returns nil when the piece type doesn't exist" do
      invalid_move = "mc4"

      validated_move = chess_game.validate_move(invalid_move)
      expect(validated_move).to be nil
    end

    it "returns nil when the move is out of bounds" do
      invalid_move = "rc9"

      validated_move = chess_game.validate_move(invalid_move)
      expect(validated_move).to be nil 
    end

    it "returns nil when there are no pieces available to make a move" do
      chess_board.current_turn = "White"

      invalid_move = "e5"

      validated_move = chess_game.validate_move(invalid_move)
      expect(validated_move).to be nil 
    end

    it "returns the move if all above checks pass" do
      chess_board.swap_players

      knight = Knight.new("Black", [7, 6])
      chess_board.add_piece(knight, knight.position)

      move = "nf6"

      validated_move = chess_game.validate_move(move)
      expect(validated_move).to eq(move)
    end
  end

  describe "#load_board" do
    before do
      new_board = Board.new
      new_board.board = new_board.generate_board
      allow(chess_game).to receive(:load_save).and_return(new_board)
      allow(Serializer).to receive(:get_save_amount).and_return(5)
    end
    
    it "calls Serializer's load_save" do
      expect(chess_game).to receive(:load_save)
      chess_game.load_board(7)
    end
    
    it "calls Serializer's load_save" do
      expect(Serializer).to receive(:get_save_amount)
      chess_game.load_board(5)
    end

    it "sets the chess_board's save number to the one provided" do
      chess_game.load_board(5)
      expect(chess_board.save_number).to eq(5)
    end
  end

  describe "#save_board" do
    before do
      allow(chess_game).to receive(:create_save).and_return(4)
      # allow(chess_game).to receive(:create_save).and_return(4)
      allow(Serializer).to receive(:update_save_numbers)
      allow(chess_game).to receive(:update_save)

    end

    it "calls Serializer's create_save if it's a new game" do
      chess_board.instance_variable_set(:@new_game, true)
      expect(chess_game).to receive(:create_save)
      chess_game.save_board
    end

    # it "calls Serializer's update_save_numbers if it's a new game" do
    #   chess_board.instance_variable_set(:@new_game, true)
    #   expect(Serializer).to receive(:update_save_numbers)
    #   chess_game.save_board
    # end

    it "sets chess_board's new game to false" do
      chess_board.instance_variable_set(:@new_game, true)
      chess_game.save_board
      new_game_check = chess_board.new_game
      expect(new_game_check).to be false
    end
  
    it "calls Serializer's update save if new game is false" do
      chess_board.instance_variable_set(:@new_game, false)
      expect(chess_game).to receive(:update_save)
      chess_game.save_board
    end
  end

  describe "#check_for_promotion" do
    before do
      # promotion choice is a Knight
      allow(chess_game).to receive(:receive_promotion_prompt).and_return("n")
    end

    it "returns nil if the piece isn't a Pawn" do
      white_bishop = Bishop.new("White", [4, 4])
      result = chess_game.check_for_promotion(white_bishop)

      expect(result).to be nil
    end

    it "promotes the white Pawn if it's on the last row" do
      white_pawn = Pawn.new("White", [7, 2])
      chess_game.check_for_promotion(white_pawn)

      target_square = test_board[7][2]
      expect(target_square.piece).to be_a Knight
    end

    it "promotes the black Pawn if it's on the last row" do
      chess_board.swap_players

      black_pawn = Pawn.new("Black", [0, 6])
      chess_game.check_for_promotion(black_pawn)

      target_square = test_board[0][6]
      expect(target_square.piece).to be_a Knight
    end
  
    it "returns nil if the piece is invalid" do
      weird_input = "fumofumo"
      result = chess_game.check_for_promotion(weird_input)
      expect(result).to be nil
    end
  end

  # current turn matters, use chess_board.swap_players
  describe "#castle" do
    it "returns nil if the move length isn't 3" do
      weird_move = "c"

      result = chess_game.castle(weird_move)
      expect(result).to be nil
    end

    it "successfully castles the white king short given valid input" do
      valid_move = "kg1"

      king = King.new("White", [0, 4])
      chess_board.add_piece(king, king.position)

      rook = Rook.new("White", [0, 7])
      chess_board.add_piece(rook, rook.position)

      chess_game.castle(valid_move)

      king_position_after = test_board[0][6]
      rook_position_after = test_board[0][5]

      castle_check = king_position_after.piece.instance_of?(King) &&
                     rook_position_after.piece.instance_of?(Rook)

      expect(castle_check).to be true
    end

    it "successfully castles the black king short given valid input" do
      chess_board.swap_players

      valid_move = "kg8"

      king = King.new("Black", [7, 4])
      chess_board.add_piece(king, king.position)

      rook = Rook.new("Black", [7, 7])
      chess_board.add_piece(rook, rook.position)

      chess_game.castle(valid_move)

      king_position_after = test_board[7][6]
      rook_position_after = test_board[7][5]

      castle_check = king_position_after.piece.instance_of?(King) &&
                     rook_position_after.piece.instance_of?(Rook)

      expect(castle_check).to be true
    end

    it "successfully castles the white king long given valid input" do
      valid_move = "kc1"

      king = King.new("White", [0, 4])
      chess_board.add_piece(king, king.position)

      rook = Rook.new("White", [0, 0])
      chess_board.add_piece(rook, rook.position)

      chess_game.castle(valid_move)

      king_position_after = test_board[0][2]
      rook_position_after = test_board[0][3]

      castle_check = king_position_after.piece.instance_of?(King) &&
                     rook_position_after.piece.instance_of?(Rook)

      expect(castle_check).to be true
    end

    it "successfully castles the white king long given valid input" do
      chess_board.swap_players

      valid_move = "kc8"

      king = King.new("Black", [7, 4])
      chess_board.add_piece(king, king.position)

      rook = Rook.new("Black", [7, 0])
      chess_board.add_piece(rook, rook.position)

      chess_game.castle(valid_move)

      king_position_after = test_board[7][2]
      rook_position_after = test_board[7][3]

      castle_check = king_position_after.piece.instance_of?(King) &&
                     rook_position_after.piece.instance_of?(Rook)

      expect(castle_check).to be true
    end
    it "returns 'castle' when castle is successful & given valid input" do
      valid_move = "kc1"

      king = King.new("White", [0, 4])
      chess_board.add_piece(king, king.position)

      rook = Rook.new("White", [0, 0])
      chess_board.add_piece(rook, rook.position)

      castle_output = chess_game.castle(valid_move)

      expect(castle_output).to eq("castle")
    end
  end

  describe "#mark_piece_as_moved" do
    it "marks Pawn as moved" do
      pawn = Pawn.new("White", [0, 0])
      chess_game.mark_piece_as_moved(pawn)
      expect(pawn.moved).to be true
    end

    it "marks Rook as moved" do
      rook = Rook.new("Black", [4, 2])
      chess_game.mark_piece_as_moved(rook)
      expect(rook.moved).to be true
    end

    it "marks King as moved" do
      king = King.new("White", [4, 4])
      chess_game.mark_piece_as_moved(king)
      expect(king.moved).to be true
    end

    it "raises NoMethodError when trying to mark Bishop as moved" do
      bishop = Bishop.new("White", [5, 2])
      chess_game.mark_piece_as_moved(bishop)
      expect { bishop.moved }.to raise_error(NoMethodError)
    end
  end

    describe "#generate_pieces_in_range" do
    it "returns two pawns when they're in range" do
      move = "e5"

      pawn_one = Pawn.new("White", [3, 3])
      chess_board.add_piece(pawn_one, pawn_one.position)

      pawn_two = Pawn.new("White", [3, 5])
      chess_board.add_piece(pawn_two, pawn_two.position)

      pawn_three = Pawn.new("Black", [4, 4])
      chess_board.add_piece(pawn_three, pawn_three.position)

      pieces_in_range = chess_game.generate_pieces_in_range(move)

      pawn_range_check = pieces_in_range[0].instance_of?(Pawn) &&
                        pieces_in_range[1].instance_of?(Pawn)

      expect(pawn_range_check).to be true
    end

    it "returns a Knight when it's in range" do
      move = "nf7"
      knight = Knight.new("White", [5, 3])
      chess_board.add_piece(knight, knight.position)

      pieces_in_range = chess_game.generate_pieces_in_range(move)
      expect(pieces_in_range[0]).to be_a Knight
    end

    it "returns a Bishop when in range" do
      chess_board.swap_players

      move = "be4"

      bishop = Bishop.new("Black", [1, 6])
      chess_board.add_piece(bishop, bishop.position)

      pieces_in_range = chess_game.generate_pieces_in_range(move)

      bishop_range_check = pieces_in_range[0].instance_of?(Bishop)

      expect(bishop_range_check).to be true
    end

    it "returns two queens when they are both in range" do
      move = "nd6"

      queen_one = Queen.new("White", [3, 1])
      chess_board.add_piece(queen_one, queen_one.position)

      queen_two = Queen.new("White", [3, 5])
      chess_board.add_piece(queen_two, queen_two.position)

      pieces_in_range = chess_game.generate_pieces_in_range(move)

      knight_range_check = pieces_in_range.all? { |p| p.instance_of?(Queen)}

      expect(knight_range_check).to be true
    end

    it "returns an empty array when no pieces are in range" do
      target_square = [4, 2]
      pieces_in_range = chess_game.generate_pieces_in_range(target_square)

      expect(pieces_in_range).to be_empty
    end
  end

  # remember to use chess_board.swap_players
  describe "#checkmate?" do
    it "returns true when the White king is checkmated" do
      # checkmate is calculated from the
      # perspective of the opponent
      chess_board.swap_players

      king = King.new("White", [6, 7])
      chess_board.add_piece(king, king.position)

      queen = Queen.new("Black", [6, 5])
      chess_board.add_piece(queen, queen.position)

      rook = Rook.new("Black", [4, 7])
      chess_board.add_piece(rook, rook.position)

      checkmate_check = chess_game.checkmate?

      expect(checkmate_check).to be true
    end

    it "returns true when the Black king is checkmated" do
      king = King.new("Black", [7, 0])
      chess_board.add_piece(king, king.position)

      queen = Queen.new("White", [5, 0])
      chess_board.add_piece(queen, queen.position)

      king_two = King.new("White", [6, 2])
      chess_board.add_piece(king_two, king_two.position)

      checkmate_check = chess_game.checkmate?

      expect(checkmate_check).to be true
    end

    it "returns false when the White king can escape" do
      chess_board.swap_players

      king = King.new("White", [7, 7])
      chess_board.add_piece(king, king.position)

      queen = Queen.new("Black", [7, 5])
      chess_board.add_piece(queen, queen.position)

      checkmate_check = chess_game.checkmate?

      expect(checkmate_check).to be false
    end

    it "returns false when the White king is guarded" do
      chess_board.swap_players

      pawn_one = Pawn.new("White", [1, 1])
      chess_board.add_piece(pawn_one, pawn_one.position)

      pawn_two = Pawn.new("White", [1, 2])
      chess_board.add_piece(pawn_two, pawn_two.position)

      king = King.new("White", [0, 0])
      chess_board.add_piece(king, king.position)

      queen = Queen.new("Black", [0, 3])
      chess_board.add_piece(queen, queen.position)

      checkmate_check = chess_game.checkmate?

      expect(checkmate_check).to be false
    end

    it "returns false when the Black king can escape" do
      king = King.new("Black", [6, 6])
      chess_board.add_piece(king, king.position)

      queen = Queen.new("White", [5, 4])
      chess_board.add_piece(queen, queen.position)

      rook = Rook.new("White", [4, 7])
      chess_board.add_piece(rook, rook.position)

      checkmate_check = chess_game.checkmate?

      expect(checkmate_check).to be false
    end

    it "returns false when the Black king is guarded" do
      king = King.new("Black", [7, 7])
      chess_board.add_piece(king, king.position)
      
      rook = Rook.new("Black", [7, 6])
      chess_board.add_piece(rook, rook.position)

      queen = Queen.new("White", [7, 4])
      chess_board.add_piece(queen, queen.position)

      rook_two = Rook.new("White", [6, 4])
      chess_board.add_piece(rook_two, rook_two.position)

      checkmate_check = chess_game.checkmate?

      expect(checkmate_check).to be false
    end

    it "sets final_message to 'checkmate'" do
      king = King.new("Black", [7, 7])
      chess_board.add_piece(king, king.position)

      queen = Queen.new("White", [7, 4])
      chess_board.add_piece(queen, queen.position)

      rook_two = Rook.new("White", [6, 4])
      chess_board.add_piece(rook_two, rook_two.position)

      chess_game.checkmate?

      final_message_check = chess_game.instance_variable_get(:@final_message)

      expect(final_message_check).to eq("checkmate")
    end
  end

  describe "#stalemate?"
end