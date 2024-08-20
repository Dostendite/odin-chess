require_relative "piece.rb"

# bishop class
# -- can freely move in the diagonal axes,
# -- but only within its own square color
class Bishop < Piece
  attr_reader :horizontal_range, :vertical_forward_range,
  :vertical_backward_range, :diagonal_forward_range, :diagonal_backward_range

  def initialize(color, position)
    super(color, position)
    @symbol = "B"

    @horizontal_range = 0
    @vertical_forward_range  = 0
    @vertical_backward_range = 0
    @diagonal_forward_range  = 7
    @diagonal_backward_range = 7
  end
end