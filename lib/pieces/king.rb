require_relative "piece.rb"

# king class
# -- can move one square in any direction
# -- can be check & mated
class King < Piece
  attr_accessor :can_castle, :in_check
  attr_reader :horizontal_range, :vertical_forward_range,
  :vertical_backward_range, :diagonal_forward_range, :diagonal_backward_range

  def initialize(color, position)
    super(color, position)
    @symbol = "K"
    @can_castle = true
    @in_check = false
    @horizontal_range = 1
    @vertical_forward_range  = 1
    @vertical_backward_range = 1
    @diagonal_forward_range  = 1
    @diagonal_backward_range = 1
  end
end