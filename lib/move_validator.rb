module MoveValidator
  include Display

  def play_move
    display
  end

  def run_simulation(condition)
    # condition could be to block
  end

  def possible_move?(piece_type, target_position)
    # check if there's any piece that could go
    # there (perhaps by running a simulation?)

    # if it returns two or more pieces, then that means
    # there must be a disambiguation
  end

  def squares_cleared?(target_position)
    # run for all pieces except
    # the knight, this method checks
    # if there's a piece obstructing
    # the desired path
  end

  def under_attack?(row, column)
    # return true if a square is under attack
    # scan all possible moves from all pieces
    # this might be the most important
    # predicate method, as it will
    # help find out what moves are legal
    # (especially in situations where the
    # king is under multiple threats, and
    # tactics like pins & skewers)
  end

  def legal_move?(piece_position, target_position)
    # under_attack?(@current_turn.king) && 
    !move_out_of_bounds?(target_position)
    # squares_cleared?(target_position)
    # return true if a move is legal
    # cases:
    # king moves into a place where it can get captured
    # 
  end

  # Optimize: Make it so that the player
  # can just input the move notation
  # https://en.wikipedia.org/wiki/Algebraic_notation_(chess)
  def disambiguate_piece_moves
    # when multiple pieces of the
    # same type can move to the same
    # square, return those pieces
    # to prompt the player for a choice
  end

  def translate_coordinates(position)
    # "d4" -> [3][3]
    pair_output = []
  
    row = (position[1].to_i) - 1
    column = (position[0].ord) - ORD_BASE
  
    pair_output << row
    pair_output << column
  end
  
  def translate_coordinates_reverse(row, column)
    # [1][7] -> "h2"
    algebraic_output = ""
  
    number = (row + 1).to_s
    letter = (column + ORD_BASE).chr
  
    algebraic_output << letter
    algebraic_output << number
  end
end