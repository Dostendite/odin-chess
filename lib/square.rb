require "rainbow"

# square class
# -- job is to provide the board with building
# -- blocks and store the pieces within
class Square
  attr_reader :coordinate, :color
  attr_accessor :piece, :en_passant_white, :en_passant_black

  # the coordinate is represented with
  # algebraic notation, e.g.: c4 -> (5, 2)
  def initialize(color, coordinate)
    @color = color
    @coordinate = coordinate
    @piece = nil
    @symbol = nil
    @en_passant_white = false
    @en_passant_black = false
  end

  def en_passant_available?(color)
    return true if color == "White" && @en_passant_black
    return true if color == "Black" && @en_passant_white
  end

  def friendly?(color)
    return false if empty?

    @piece.color == color
  end

  def opposing?(color)
    return false if empty?

    @piece.color != color
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