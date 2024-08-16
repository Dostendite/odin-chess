require_relative "piece.rb"

# queen class
# -- has the combined set of moves of
# -- the king, rook, and bishop
class Queen < Piece
  def initialize(color, position)
    super(color, position)
    @symbol = "Q"
  end
end