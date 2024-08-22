require "pry-byebug"

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

  def play_chess
    introduce_player
    show_reminder
    play_game
  end
  
  def introduce_player
    Serializer.update_save_numbers
    display_introduction
  end

  def start_new_game
    @chess_board = Board.new
    @chess_board.board = @chess_board.generate_board
    @chess_board.setup_pieces
    @chess_board.save_board
  end

  def show_reminder
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

  # main game loop - add stalemate, en passant & checkmate
  def play_game
    loop do
      menu_prompt = show_main_menu
      next unless %W(new load).include?(menu_prompt)

      until @game_over
        piece, move_pair = prompt_move

        if move_pair == "main menu"
          @chess_board.save_board
          break
        end

        make_move(piece, move_pair)
        next_turn
      end
    end
    display_final_message
  end

  def show_main_menu
    main_menu_choice = receive_main_menu_choice
    process_main_menu_choice(main_menu_choice)
  end

  def process_main_menu_choice(main_menu_choice)
    case main_menu_choice
    when "new"
      start_new_game
      return "new"
    when "delete"
      display_main_menu(2)
      delete_save(receive_delete_choice)
      Serializer.update_save_numbers
    when "load"
      display_main_menu(1)
      load_game(receive_load_choice)
      return "load"
    end
  end

  def next_turn
    @chess_board.swap_players
    @chess_board.save_board
  end

  def make_move(piece, move_pair)
    @chess_board.move_piece(piece, move_pair)
  end

  def generate_piece_choices(move)
    if move.length == 2
      generate_pawn_choices(move)
    else
      generate_pieces_in_range(@chess_board, move)
    end
  end

  def prompt_move(board_message = 0)
    move = receive_move_prompt(board_message)
    return nil, "main menu" if move == "main menu"

    piece_choices = generate_piece_choices(move)

    if piece_choices.length > 1
      piece_choice = prompt_multiple_move_choices(piece_choices)
    else
      piece_choice = piece_choices
    end

    return piece_choice, move[-2..]
  end

  # move these to the validator
  def target_square_friendly?(target_square)
    if !target_square.empty?
      target_square.piece.color == @chess_board.current_turn
    end
  end

  def target_square_unfriendly?(target_square)
    if !target_square.empty?
      target_square.piece.color != @chess_board.current_turn
    end
  end

  def generate_pawn_choices(move)
    move_pair = translate_to_pair(move[-2..])
    target_row, target_column = move_pair
    target_square = @chess_board.board[target_row][target_column]

    if target_square_friendly?(target_square)
      prompt_move("move not valid") 
    elsif target_square_unfriendly?(target_square)
      @chess_board.find_attacking_pawns(move_pair)
    else
      generate_peaceful_pawn_choices(move_pair)
    end
  end

  def generate_peaceful_pawn_choices(move_pair)
    pawn_one_below = @chess_board.find_pawn_below(move_pair, 1)
    pawn_two_below = @chess_board.find_pawn_below(move_pair, 2)

    if !pawn_one_below.nil?
      return [pawn_one_below]
    elsif !pawn_two_below.nil?
      return [pawn_two_below]
    else
      prompt_move("move not valid")
    end
  end

  def check_game_over
    # mated_color = find_checkmate
    # display_checkmate_message(mated_color)
    # ^^ under the board
    # delete the save
    # @game_over = true
  end

  def load_game(save_number)
    Serializer.update_save_numbers
    @chess_board = Board.new
    @chess_board.load_board(save_number)
  end

  def receive_move_prompt(board_message)
    loop do
      display_board(@chess_board.board, board_message)
      display_move_prompt(@chess_board.current_turn)
      move = gets.chomp
      return "main menu" if %W(main menu).include?(move)
      
      return validate_move(move) unless validate_move(move).nil?
    end
  end

  def validate_move(move)
    if move.length < 1 || move.length > 3
      return nil
    elsif move.length > 2
      target_piece_type = @chess_board.find_piece_class(move[0].upcase)
      return nil if target_piece_type.nil?
    elsif move_out_of_bounds?(translate_to_pair(move[-2..]))
     return nil
    else
      move
    end
  end

  private

  def prompt_multiple_move_choices(piece_choices)
    loop do
      print_board(@chess_board.board)
      display_multiple_move_choice(piece_choices)
      choice = gets.chomp.to_i
      target_piece = piece_choices[choice - 1]

      return target_piece if piece_choices.include?(target_piece)
    end
  end

  def receive_main_menu_choice
    message_id = 0
    loop do
      display_main_menu(message_id)
      menu_choice = gets.strip.downcase
      if menu_choice == "new" && Serializer.max_saves?
        message_id = 3
      elsif %W(new load delete).include?(menu_choice)
        return menu_choice 
      else
        message_id = 4
      end
    end
  end

  def receive_load_choice
    save_numbers = Serializer.get_save_numbers
    loop do
      load_choice = gets.to_i
      return load_choice if save_numbers.include?(load_choice.to_i)
        
      display_main_menu
      puts "Please input a valid save number to load!"
    end
  end

  def receive_delete_choice
    save_numbers = Serializer.get_save_numbers
    loop do
      delete_choice = gets.to_i
      return delete_choice if save_numbers.include?(delete_choice)
  
      display_main_menu
      puts "Please input a valid save number to delete!"
    end
  end
end
