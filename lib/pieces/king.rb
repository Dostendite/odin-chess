require_relative "piece.rb"

# king class
# -- can move one square in any direction
# -- can be check & mated
class King < Piece
  attr_accessor :can_castle, :in_check

  def initialize(color, position)
    super(color, position)
    @symbol = "K"
    @can_castle = true
    @in_check = false
  end
end