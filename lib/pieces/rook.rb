require_relative "piece.rb"

# rook class
# -- can freely move in the horizontal
# -- and vertical axes
class Rook < Piece
  attr_accessor :can_castle
  attr_reader :horizontal_range, :vertical_forward_range, 
              :vertical_backward_range

  def initialize(color, position)
    super(color, position)
    @symbol = "R"
    @can_castle = true
    @horizontal_range = 7
    @vertical_forward_range  = 7
    @vertical_backward_range = 7
  end
end