class Square
  def initialize(color, coordinate)
    @color = color
    @coordinate = coordinate
    @piece = nil
  end

  def has_piece?
    !piece.nil?
  end

  def black?
    @color == "black"
  end
end