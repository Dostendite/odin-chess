require_relative "piece.rb"

# rook class
# -- can freely move in the horizontal
# -- and vertical axes
class Rook < Piece
  attr_accessor :moved
  attr_reader :axes

  def initialize(color, position)
    super(color, position)
    @symbol = "♜♖"
    @moved = false
    @axes = { x: 7, y: 7, d: 0 }
  end
end