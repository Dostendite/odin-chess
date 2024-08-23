require_relative "piece.rb"

# king class
# -- can move one square in any direction
# -- can be check & mated
class King < Piece
  attr_accessor :moved, :in_check
  attr_reader :axes

  def initialize(color, position)
    super(color, position)
    @symbol = "♚♔"
    @moved = false
    @in_check = false
    @axes = { x: 1, y: 1, d: 1 }
  end
end
