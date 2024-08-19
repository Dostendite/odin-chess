require_relative "piece.rb"

# bishop class
# -- can freely move in the diagonal axes,
# -- but only within its own square color
class Bishop < Piece
  def initialize(color, position)
    super(color, position)
    @symbol = "B"
  end
end