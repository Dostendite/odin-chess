require_relative "piece.rb"

# queen class
# -- has the combined set of moves of
# -- the king, rook, and bishop
class Queen < Piece
  attr_reader :axes

  def initialize(color, position)
    super(color, position)
    @symbol = "Q"
    @axes = { x: 7, y: 7, d: 7 }
  end
end