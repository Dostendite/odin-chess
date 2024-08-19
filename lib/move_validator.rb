module MoveValidator
  include Display
  def valid_pawn_move?(pawn_move_choice)
    row, column = translate_coordinates(pawn_move_choice)
    return false if move_out_of_bounds?(row, column)
    return false if !pawn_in_reach?(row, column)
  end

  def pawn_in_reach?(target_row, target_column)
    if @current_turn == "White"
      one_below = @board[row - 1][column]
      if one_below.piece.instance_of?(Pawn)
        one_below.piece.can_double_jump = false
        return true
      end
    else
      one_above = @board[row + 1][column]
      if one_above.piece.instance_of?(Pawn)
        one_above.piece.can_double_jump = false
        return true
      end
    end
  end

  def process_move_choice(move_choice)
    play_menu if move_choice == "main"

    if move_choice.include?("pawn")
      if board.valid_pawn_move?(move_choice)
        board.play_move()
      else
        play_game("illegal")
      end
    end
  end

  def prompt_move_choice
    display_move_prompt
    receive_move_choice
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

    # NITTY GRITTY
    def receive_move_choice
      move_choice = gets.chomp
      return "main" if move_choice[0..3] == "main"
  
      move_choice = validate_algebraic_notation(move_choice)
    end
  
    def validate_algebraic_notation(move_choice)
      # binding.pry
      if move_choice.length < 2 || move_choice.length > 4
        play_move("move not valid")
      elsif board.move_out_of_bounds?(move_choice[-2..])
        play_move("move not valid")
      elsif move_choice.length == 2
        return validate_pawn_move_choice(move_choice)
      elsif !board.pieces_include?(move_choice[0])         
        play_move("move not valid")
      else
        return validate_piece_move_choice(move_choice)
      end
    end
  
    def validate_pawn_move_choice(pawn_move_choice)
      if board.valid_pawn_move?(pawn_move_choice)
        pawn_move_choice + "pawn"
      end
    end
  
  def validate_piece_move_choice(algebraic_move_choice)
    # check for moves that would leave the king in check,
    # and those outside of the reach of the pieces
    piece_choice = algebraic_move_choice[0].downcase
    position_choice = algebraic_move_choice[-2..].downcase

    # binding.pry
    play_move("illegal") if !board.piece_available?(piece_choice)
    
    algebraic_move_choice
  end
end