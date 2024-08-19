require_relative "board"
require_relative "chess"
require_relative "square"
require_relative "display"
require_relative "serializer"
require_relative "move_validator"

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
  include MoveValidator
  attr_reader :board

  def initialize
    @chess_board = nil
    @game_over = false
    @displayed_reminder = false
    @displayed_en_passant = false
  end
  
  def introduce_player
    Serializer.update_save_numbers
    display_introduction
  end

  def play_menu
    display_main_menu
    process_menu_choice(receive_main_menu_choice)
    unless @displayed_reminder
      display_main_menu_reminder
      @displayed_reminder = true
    end
  end

  # -------- CHESS --------
  # 1. Set up the board & pieces
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

  # main game loop - add stale, en passant & checkmate
  def start_new_game
    @chess_board = Board.new
    @chess_board.create_new_board
    @chess_board.setup_pieces
    @chess_board.save_board
    Serializer.update_save_numbers
    play_game
  end

  def play_game
    until @game_over
      MoveValidator.update_board(@chess_board)
      play_move
      @chess_board = MoveValidator.export_board
      @chess_board.swap_players
      @chess_board.save_board
    end
    display_final_message
  end

  def game_over
    # mated_color = find_checkmate
    # display_checkmate_message(mated_color)
    # ^^ under the board
    # @game_over = true
  end

  # ???
  def leave_game
    @chess_board.save_board
    play_menu
  end

  def load_game(save_number)
    Serializer.update_save_numbers
    @chess_board = Board.new
    @chess_board.load_board(save_number)
  end

  def process_menu_choice(play_choice)
    if play_choice == "new" && Serializer.get_save_amount > 7
      display_main_menu(3)
      process_menu_choice(receive_main_menu_choice)
    elsif play_choice == "new"
      start_new_game
    elsif play_choice == "delete"
      delete_save(prompt_delete_choice)
      Serializer.update_save_numbers
      play_menu
    elsif play_choice == "load"
      display_main_menu(1)
      load_game(receive_load_choice)
    end
    play_game
  end
  
  def prompt_delete_choice
    display_main_menu(2)
    receive_delete_choice
  end

  private
  # Receive methods - Find a way to optimize
  # them (better input validation & regex?)
  def receive_main_menu_choice
    loop do
      menu_choice = gets.strip.downcase
      if menu_choice[0] == "n" || menu_choice == ""
        return "new"
      elsif menu_choice[0] == "d"
        return "delete"
      elsif menu_choice[0] == "l"
        return "load"
      else
        display_main_menu
        puts "Please enter 'new', 'load, or 'delete'!"
        puts
      end
    end
  end

  def receive_load_choice
    save_numbers = Serializer.get_save_numbers
    loop do
      load_choice = gets.to_i
      if save_numbers.include?(load_choice.to_i)
        return load_choice
      else
        display_main_menu
        puts "Please input a valid save number to load!"
      end
    end
  end

  def receive_delete_choice
    save_numbers = Serializer.get_save_numbers
    loop do
      delete_choice = gets.to_i
      if save_numbers.include?(delete_choice)
        return delete_choice
      else
        display_main_menu
        puts "Please input a valid save number to delete!"
      end
    end
  end
end

