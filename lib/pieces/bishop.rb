require_relative "piece.rb"

# bishop class
# -- can freely move in the diagonal axes,
# -- but only within its own square color
class Bishop < Piece
  attr_reader :axes

  def initialize(color, position)
    super(color, position)
    @symbol = "♝♗"
    @axes = { x: 0, y: 0, d: 7 }
  end
end