# piece class
# -- job is to act as a superclass and provide
# -- a basis for every piece in the game
class Piece
  attr_reader :color, :symbol
  attr_accessor :position

  # the position is represented as a
  # row / column pair, e.g.: [5, 2] (c4)
  def initialize(color, position)
    @color = color
    @position = position
  end

  def black?
    @color == "Black"
  end
end