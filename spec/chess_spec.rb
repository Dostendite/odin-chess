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
  describe "#play_chess" do
    subject(:chess_game) { described_class.new }

    before do
      allow(chess_game).to receive(:introduce_player)
      allow(chess_game).to receive(:show_reminder)
      allow(chess_game).to receive(:play_game)
    end

    it "introduces the player" do
      expect(chess_game).to receive(:introduce_player)
      chess_game.play_chess
    end

    it "shows the main menu reminder" do
      expect(chess_game).to receive(:show_reminder)
      chess_game.play_chess
    end

    it "plays the game" do
      expect(chess_game).to receive(:play_game)
      chess_game.play_chess
    end
  end

  describe "#introduce_player" do
    subject(:chess_game) { described_class.new }

    before do
      allow(Serializer).to receive(:update_save_numbers)
      allow(chess_game).to receive(:display_introduction)
    end

    it "updates the seriailizer save numbers" do
      expect(Serializer).to receive(:update_save_numbers)
      chess_game.introduce_player
    end

    it "displays the introduction" do
      expect(chess_game).to receive(:display_introduction)
      chess_game.introduce_player
    end
  end

  describe "#make_move" do
    subject(:chess_game) { described_class.new }

    before do
      chess_game.start_new_game
      allow_any_instance_of(Board).to receive(:move_piece)
    end

    it "tells the chess board to move a piece" do
      chess_board = chess_game.instance_variable_get(:@chess_board)
      expect(chess_board).to receive(:move_piece)
      chess_game.make_move("piece", "position")
    end
  end
end