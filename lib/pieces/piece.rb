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

  def horizontal_move?
    return "range"
  end

  def vertical_move?
    return "range"
  end

  def fetch_horizontal_move(range); end
  def fetch_vertical_move(range); end
  def fetch_diagonal_move(range); end
  def fetch_knight_move; end
end