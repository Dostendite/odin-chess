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
    @displayed_reminder = false
    @displayed_en_passant = false
  end

  # main game loop
  def play_game
    until @game_over
      print_board
      process_move_choice(prompt_move_choice)
    end
  end

  def play_menu
    display_main_menu
    process_menu_choice(receive_main_menu_choice)
    unless @displayed_reminder
      display_main_menu_reminder
      @displayed_reminder = true
    end
  end

  def introduce_player
    Serializer.update_save_numbers
    display_introduction
  end

  def print_board
    display_board(@board.board)
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

  def play_move(piece, position)
    @board.move_piece
  end

  def create_new_game
    @board = Board.new
    @board.create_new_board
    @board.setup_pieces
    @board.save_board
    Serializer.update_save_numbers
    play_game
  end

  def leave_game
    @board.save_board
    play_menu
  end

  def load_game(save_number)
    Serializer.update_save_numbers
    @board = Board.new
    @board.load_board(save_number)
  end

  def process_menu_choice(play_choice)
    if play_choice == "new" && Serializer.get_save_amount > 7
      display_main_menu(3)
      process_menu_choice(receive_main_menu_choice)
    elsif play_choice == "new"
      create_new_game
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

  def process_move_choice(move_choice)
    if move_choice == "main"
      play_menu
    end
  end
  
  def prompt_delete_choice
    display_main_menu(2)
    receive_delete_choice
  end

  def prompt_move_choice
    display_move_prompt
    receive_move_choice
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

  # NITTY GRITTY
  def receive_move_choice
    move_choice = gets.chomp
    if move_choice[0..3] == "main"
      return "main"
    else
      move_choice
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

