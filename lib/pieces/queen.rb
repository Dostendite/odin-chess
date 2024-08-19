require_relative "piece.rb"

# queen class
# -- has the combined set of moves of
# -- the king, rook, and bishop
class Queen < Piece
  attr_reader :horizontal_range, :vertical_forward_range,
  :vertical_backward_range, :diagonal_forward_range, :diagonal_backward_range

  def initialize(color, position)
    super(color, position)
    @symbol = "Q"
    @horizontal_range = 7
    @vertical_forward_range  = 7
    @vertical_backward_range = 7
    @diagonal_forward_range  = 7
    @diagonal_backward_range = 7
  end
end