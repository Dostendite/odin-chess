require "pry-byebug"

require_relative "display"

module MoveValidator
  include Display
  # Chain Structure
  # -- returns true if the move is valid and allows it,
  # -- else it displays and error ("move not valid"), ("under check"), etc
  # if an error bubbles up, restart & display the error once
  # else, allow the move
  def make_move(board, msg_type = 0)
    display_board(board.board, msg_type)
    display_move_prompt(board.current_turn)
    move = prompt_for_move
    process_move(board, move)
  end

  def process_move(board, move)
    return "menu" if move.include?("main") || move.include?("menu")

    move_algebraic = validate_move_algebraic(move_algebraic)
    process_move_algebraic(board, move)
  end

  def validate_move_algebraic(move_algebraic)
    # make checks to ensure the input
    # complies:
    # 1. the piece exists
    # 2. the coordinate makes sense
    # else call make_move("move not valid")
    move_algebraic
  end

  def process_move_algebraic(board, move_algebraic)
    if move_algebraic.length == 2
      process_pawn_move(board, move_algebraic)
    else
      process_piece_move_algebraic(board, move_algebraic)
    end
  end

  def process_pawn_move(board, move_algebraic)
    target_position_pair = translate_to_pair(move_algebraic[-2..])
    target_row, target_column = target_position_pair
    target_square = board.board[target_row][target_column]

    # find attacking pawns
    if !target_square.empty?
      # not valid if piece is friendly
      if target_square.piece.color == board.current_turn
        make_move(board, "move not valid")
      end

      attacking_pawns_in_range = board.find_attacking_pawns(target_position_pair)
      if attacking_pawns_in_range.length > 1
        disambiguate_piece_moves(board, attacking_pawns_in_range)
      else
        board.move_piece(attacking_pawns_in_range[0], target_position_pair)
      end
      return
    end

    # square is free
    pawn_one_below = board.find_pawn_below(target_position_pair, 1)
    pawn_two_below = board.find_pawn_below(target_position_pair, 2)

    if !pawn_one_below.nil?
      board.move_piece(pawn_one_below, target_position_pair)
    elsif !pawn_two_below.nil?
      board.move_piece(pawn_two_below, target_position_pair)
    else
      play_move("move not valid")
    end
    # pawn_two_below = board.find_pawn_two_below(target_position_pair)
    # board.move_piece(pawn_one_below, target_position_pair)
  end

  def process_piece_move_algebraic(board, move_algebraic)
    target_piece_type = board.find_piece_class(move_algebraic[0].upcase)
    target_position_pair = translate_to_pair(move_algebraic[-2..])
    pieces_in_range = board.find_pieces_in_range(target_piece_type, target_position_pair)

    make_move(board, "move not valid") if pieces_in_range.length < 1

    if pieces_in_range.length > 1
      disambiguate_piece_moves(board, pieces_in_range, target_position_pair)
    elsif pieces_in_range.length == 1
      board.move_piece(pieces_in_range[0], target_position_pair)
    end
  end

  def disambiguate_piece_moves(board, piece_choices, target_position_pair)
    display_board(board.board)
    piece_to_move = prompt_piece_to_move(board, piece_choices)
    board.move_piece(piece_choices[piece_to_move], target_position_pair)
  end

  def prompt_piece_to_move(board, pieces_in_range)
    print_board(board.board)
    display_multiple_move_prompt(pieces_in_range)
    multiple_move_prompt = gets.chomp.to_i
    multiple_move_prompt = validate_multiple_move_prompt(multiple_move_prompt - 1)
  end

  def validate_multiple_move_prompt(multiple_move_prompt)
    multiple_move_prompt
  end

  def prompt_for_move
    move_algebraic = gets.chomp
    validate_algebraic_notation(move_algebraic)
  end

  def validate_algebraic_notation(move_algebraic)
    move_algebraic
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

# ------------------ DUMP

def run_simulation(condition)
  # condition could be to block
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