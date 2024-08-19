require_relative "piece.rb"

# knight class
# -- can jump over pieces and
# -- draw an L (2,1 || 1, 2) with its moves
class Knight < Piece
  def initialize(color, position)
    super(color, position)
    @symbol = "K"
  end
end