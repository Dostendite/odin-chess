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
    save_board
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

      # main game loop
      until @game_over
        piece, move_pair = prompt_move

        if move_pair == "main menu"
          save_board
          break
        end

        if move_pair == "castle"
          next_turn
          next
        end

        mark_piece_as_moved(piece)
        make_move(piece, move_pair)
        next_turn
      end
    end
    display_final_message
  end

  # white
  # default king pos -> e1
  # short rook pos -> h1 | long rook pos -> a1
  # squares that must be intact:
  
  # black
  # default king pos -> e8
  # short rook pos -> h8 | long rook pos -> a8

  def castle(move)
    current_turn = @chess_board.current_turn
    return nil unless @chess_board.castle_available?(current_turn)

    if move.include?("kg")
      @chess_board.castle_short(current_turn)
    elsif move.include?("kc")
      @chess_board.castle_long(current_turn)
    end

    return "castle"
  end
  
  def mark_piece_as_moved(piece)
    if piece.instance_of?(Pawn) || piece.instance_of?(King) || piece.instance_of?(Rook)
      piece.moved = true
    end
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
      load_board(receive_load_choice)
      return "load"
    end
  end

  def next_turn
    @chess_board.swap_players
    save_board
  end

  def make_move(piece, move_pair)
    @chess_board.move_piece(piece, move_pair)
  end

  def generate_piece_choices(move)
    if move.length == 2
      generate_pawn_choices(move)
    else
      generate_pieces_in_range(move)
    end
  end

  def generate_pieces_in_range(move)
    piece_type = @chess_board.find_piece_class(move[0].upcase)
    color = @chess_board.current_turn
    board = @chess_board.board

    available_pieces = find_available_pieces(board, piece_type, color)
    pieces_in_range = []
    # binding.pry
    available_pieces.each do |piece|
      squares = piece.get_valid_squares(board)
      if piece_in_range?(board, piece, squares, move)
        pieces_in_range << piece
      end
    end
    pieces_in_range
  end

  def prompt_move(board_message = 0)
    move = receive_move_prompt(board_message)

    return nil, "castle" if move == "castle"
    return nil, "main menu" if move == "main menu"

    move_pair = translate_to_pair(move[-2..])
    piece_choices = generate_piece_choices(move)

    if piece_choices.length > 1
      piece_choice = prompt_multiple_move_choices(piece_choices)
    else
      piece_choice = piece_choices[0]
    end

    return piece_choice, move_pair
  end

  # maybe move these to the validator
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
      nil
    elsif target_square_unfriendly?(target_square)
      current_turn = @chess_board.current_turn
      find_attacking_pawns(@chess_board.board, move_pair, current_turn)
    else
      generate_peaceful_pawn_choices(move_pair)
    end
  end

  def generate_peaceful_pawn_choices(move_pair)
    board = @chess_board.board
    current_turn = @chess_board.current_turn
    pawn_one_below = find_pawn_below(board, move_pair, 1, current_turn)
    return [pawn_one_below] if !pawn_one_below.nil?

    pawn_two_below = find_pawn_below(board, move_pair, 2, current_turn)
    return [pawn_two_below] if !pawn_two_below.nil?

    nil
  end

  def check_game_over
    # mated_color = find_checkmate
    # display_checkmate_message(mated_color)
    # ^^ under the board
    # delete the save
    # @game_over = true
  end

  def load_board(save_number)
    @chess_board = load_save(save_number)
    @chess_board.save_number = Serializer.get_save_amount
  end

  def save_board
    if @chess_board.new_game
      @chess_board.save_number = create_save(@chess_board)
      Serializer.update_save_numbers
      @chess_board.new_game = false
    else
      update_save(@chess_board, @chess_board.save_number)
    end
  end

  def receive_move_prompt(board_message)
    loop do
      display_board(@chess_board.board, board_message)
      display_move_prompt(@chess_board.current_turn)
      move = gets.chomp
      # binding.pry

      if %W(kg1 kg8 kc1 kc1).include?(move)
        move = castle(move)
      end

      if move.nil?
        board_message = "move not valid"
        next
      end

      return move if move == "castle"
      return "main menu" if %W(main menu).include?(move)

      # binding.pry
      validated_move = validate_move(move)
      return validated_move unless validated_move.nil?

      board_message = "move not valid"
    end
  end

  def validate_move(move)
    return nil if (move.length < 1 || move.length > 3)
    return nil if move_out_of_bounds?(translate_to_pair(move[-2..]))
      
    if move.length == 2
      pawn_choices = validate_pawn_move(move)
      return nil if pawn_choices.nil?
      return nil if pawn_choices.empty?
    else
      # binding.pry
      piece_choices = validate_piece_move(move)
      return nil if piece_choices.nil?
      return nil if piece_choices.empty?
    end
    move
  end

  def validate_pawn_move(pawn_move)
    generate_pawn_choices(pawn_move)
  end

  def validate_piece_move(piece_move)
    target_piece_type = @chess_board.find_piece_class(piece_move[0].upcase)
    return nil if target_piece_type.nil?

    piece_choices = generate_pieces_in_range(piece_move)
    return nil if piece_choices.empty? || piece_choices.nil?

    piece_choices
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
