require "rainbow"

# square class
# -- job is to provide the board with building
# -- blocks and store the pieces within
class Square
  attr_reader :coordinate, :color

  def initialize(color, coordinate)
    @color = color
    @coordinate = coordinate
    @piece = nil
  end

  def empty?
    @piece.nil?
  end

  def black?
    @color == "black"
  end
  
  def to_s
    if empty?
      "  "
    else
      "#{@piece} "
    end
  end

  def print_self
    if black?
      print Rainbow(to_s).bg("#1375d1") if black?
    else
      print Rainbow(to_s).bg("#ffffff")
    end
    # puts if @coordinate.include?("h") && !@coordinate.include?("1")
  end
end