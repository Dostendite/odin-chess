require_relative "piece.rb"

# bishop class
# -- can freely move in the diagonal axes,
# -- but only within its own square color
class Bishop < Piece
  attr_reader :diagonal_forward_range, :diagonal_backward_range

  def initialize(color, position)
    super(color, position)
    @symbol = "B"

    @diagonal_forward_range  = 7
    @diagonal_backward_range = 7
  end
end