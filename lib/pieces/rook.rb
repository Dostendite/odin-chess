require_relative "piece.rb"

# rook class
# -- can freely move in the horizontal
# -- and vertical axes
class Rook < Piece
  def initialize(color, position)
    super(color, position)
    @symbol = "R"
    @can_castle = true
  end
end