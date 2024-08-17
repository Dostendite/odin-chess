require_relative "board"
require_relative "chess"
require_relative "display"
require_relative "serializer"
require_relative "square"

require_relative "pieces/piece.rb"
require_relative "pieces/pawn.rb"
require_relative "pieces/knight.rb"
require_relative "pieces/bishop.rb"
require_relative "pieces/rook.rb"
require_relative "pieces/queen.rb"
require_relative "pieces/king.rb"

# chess game class
# -- job is to take care of the game logic,
# -- as well as to interact with the player
class Chess
  include Display
  include Serializer
  attr_reader :board

  def initialize
    @board = nil
    @game_over = false
  end

  def print_board
    display_board(@board.board)
  end

  def introduce_player
    Serializer.update_save_amount
    display_introduction
    display_main_menu
    process_play_choice(prompt_play_choice)
  end

  def play_game
    print_board
    display_continue_prompt
  end

  # -------- GAME --------
  # 1. Set up the board & the pieces
  # 2. Prompt for a move
  # 3. Move the desired piece
  # 4. Repeat
  # 5. When the king receives a check, check for checkmate
  # if the king is checkmated: the game is over
  #    -> else: let the player make only moves that stop the
  #             king from getting checkmated
  # 6. Once the game is over, thank the player for            
  # trying out the game and send them to the main menu
  # display_final_message

  def process_play_choice(play_choice)
    if play_choice == "play"
      @board = Board.new
      @board.create_new_board
      # @board.setup_pieces
      @board.save_board
    else
      @board = Board.new
      @board.load_board(play_choice)
    end
  end

  def prompt_play_choice
    receive_play_choice
  end

  def prompt_move
    # check if move is legal, else call again
    # in cases where two or more pieces can move
    # to the same square ask which one to move
  end

  def play_move(piece, position)
    @board.move_piece
  end

  private
  
  def receive_play_choice
    save_amount = Serializer.get_save_amount
    loop do
      play_choice = gets.strip
      if play_choice.nil? || play_choice == ""
        return "play"
      elsif play_choice[0].downcase == "p"
        return "play"
      else
        play_choice = play_choice.to_i
        if (1..save_amount).include?(play_choice)
          return play_choice
        else
          display_main_menu
          puts "Please input 'play' or (1 - #{save_amount})..."
        end
      end
    end
  end
end

