require "rainbow"

# square class
# -- job is to provide the board with building
# -- blocks and store the pieces within
class Square
  attr_reader :coordinate, :color
  attr_accessor :piece

  # the coordinate is represented with
  # algebraic notation, e.g.: c4 -> (5, 2)
  def initialize(color, coordinate)
    @color = color
    @coordinate = coordinate
    @piece = nil
    @symbol = nil
  end

  def empty?
    @piece.nil?
  end

  def black?
    @color == "Black"
  end
  
  def to_s
    if empty?
      "  "
    else
      if @piece.black?
        "#{@piece} "
      else
        " #{@piece}"
      end
    end
  end

  def print_self
    if black?
      print Rainbow(to_s).bg("#1375d1") if black?
    else
      print Rainbow(to_s).bg("#ffffff")
    end
  end
end