require_relative "display"

module MoveValidator
  include Display
  @@board = nil

  def self.update_board(board)
    @@board = board
  end

  def self.export_board
    @@board
  end

  # Chain Structure
  # -- returns true if the move is valid and allows it,
  # -- else it displays and error ("move not valid"), ("under check"), etc
  # if an error bubbles up, restart & display the error once
  # else, allow the move
  
  def play_move(msg_type = 0)
    display_board(@@board.board, msg_type)
    display_move_prompt(@@board.current_turn)
    move_algebraic = prompt_for_move
    process_move(move_algebraic)
  end

  require "pry-byebug"
  def process_move(move_algebraic)
    target_piece_type = @@board.find_piece_class(move_algebraic[0].upcase)
    target_position_pair = translate_to_pair(move_algebraic[-2..])
    # binding.pry

    pieces_in_range = @@board.find_pieces_in_range(target_piece_type, target_position_pair)
    
    play_move("move not valid") if pieces_in_range.length < 1

    # binding.pry
    if pieces_in_range.length > 1
      display_board(@@board.board)
      piece_to_move = prompt_piece_to_move(pieces_in_range)
      @@board.move_piece(pieces_in_range[piece_to_move], target_position_pair)
    else
      @@board.move_piece(pieces_in_range[0], target_position_pair)
    end
  end

  def prompt_piece_to_move(pieces_in_range)
    print_board(@@board.board)
    display_multiple_move_prompt(pieces_in_range)
    multiple_move_prompt = gets.chomp.to_i
    multiple_move_prompt = validate_multiple_move_prompt(multiple_move_prompt)
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