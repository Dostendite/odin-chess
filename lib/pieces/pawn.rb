require_relative "piece.rb"

# pawn class
# -- can move forwards two squares if it hasn't moved yet,
# -- move one forwards otherwise, attack one square forward
# -- diagonally, and punish another double-jumping pawn diagonally
# -- with en-passant. Can also promote to a queen, knight, 
# -- or bishop when getting to the end of the board
class Pawn < Piece
  attr_accessor :can_double_jump

  def initialize(color, position)
    super(color, position)
    @symbol = "P"
    @can_double_jump = true
  end
  # when a pawn does a double jump,
  # the first square in front
  # becomes en-passantable

  def vertical_move?
    if @can_double_jump
      "two forwards"
    else
      1
    end
  end

  def diagonal_move?; end
end