require_relative "piece.rb"

# rook class
# -- can freely move in the horizontal
# -- and vertical axes
class Rook < Piece
  attr_accessor :can_castle
  attr_reader :axes

  def initialize(color, position)
    super(color, position)
    @symbol = "♜♖"
    @can_castle = true
    @axes = { x: 7, y: 7, d: 0 }
  end
end