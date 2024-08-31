require_relative "display"

module MoveValidator
  include Display

  # RETURNS TRUE IF PIECE IS IN RANGE OF SQUARE
  def piece_in_range?(board, piece, squares, move)
    squares.any? { |square| square.coordinate == move[-2..] }
  end

  def find_available_pieces(board, piece_type, color)
    available_pieces = []
    board.each do |row|
      row.each do |square|
        next if square.empty?

        target_piece = square.piece
        if target_piece.color == color && target_piece.instance_of?(piece_type)
          available_pieces << square.piece
        end
      end 
    end
    available_pieces
  end

  def move_out_of_bounds?(target_position_pair)
    row, column = target_position_pair
    !(0..7).include?(row) || !(0..7).include?(column)
  end

  def translate_to_pair(position)
    # "d4" -> [3][3]
    pair_output = []

    row = (position[1].to_i) - 1
    column = (position[0].ord) - ORD_BASE

    pair_output << row
    pair_output << column
  end

  def translate_to_algebraic(row, column)
    # [1][7] -> "h2"
    algebraic_output = ""

    number = (row + 1).to_s
    letter = (column + ORD_BASE).chr

    algebraic_output << letter
    algebraic_output << number
  end
end