require_relative "piece.rb"

# knight class
# -- can jump over pieces and
# -- draw an L (2,1 || 1, 2) with its moves
class Knight < Piece
  attr_reader :knight_moves

  def initialize(color, position)
    super(color, position)
    @symbol = "K"
    @knight_moves = generate_knight_moves
  end

  def generate_knight_moves
    recipe = [1, 2, -1, -2]
    moves = []

    recipe.each do |number|
      recipe.each do |other|
        next if number.abs == other.abs

        moves << [number, other]
      end
    end
    moves
  end
end