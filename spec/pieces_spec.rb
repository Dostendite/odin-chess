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
      # maybe I should use let
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