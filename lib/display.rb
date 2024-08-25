require_relative "serializer"
require_relative "move_validator"

# display module
# -- job is to display the main menu, as well as
# -- the chess game and its messages
module Display
  include Serializer

  def print_board(board, board_message = 0)
    display_board(board, board_message)
  end

  def display_introduction
    clear_screen
    introduction = <<~HEREDOC
    Hello! Welcome to my very first game of Chess!
    This is the capstone project for The Odin Project's Ruby course.
    HEREDOC

    print_skyblue(introduction)
    print_skyblue("You can find me on GitHub as ")
    puts Rainbow("dostendite!").royalblue.bright
    display_continue_prompt
  end

  def display_saves
    save_numbers = Serializer.get_save_numbers
    return if save_numbers.length == 0

    save_numbers.each do |save_idx|
      puts "           [Save #{save_idx}]  "
    end
  end

  # maybe add a parameter (0, 1, 2)
  # to display it along with the 
  # new, load, delete prompt?
  def display_main_menu(id = 0)
    clear_screen
    puts Rainbow("      <~ [210's Chess] ~>").bright
    display_saves
    puts

    if Serializer.get_save_amount < 1
      puts "Input 'new' to start a new game!"
    else
      puts "Input 'new', 'load', or 'delete'!"
    end

    case id
    when 1 # load
      display_load_prompt
    when 2 # delete
      display_delete_prompt
    when 3 # max saves
      display_max_saves_message
    when 4
      display_main_menu_error
    end
  end

  def display_board(board, board_message = 0, winner_color = nil)
    clear_screen
    board.reverse.each_with_index do |row, index|
      row.each do |square|
        if square.coordinate.include?("a")
          print Rainbow("#{square.coordinate[1]} ").bright
        end
        square.print_self
      end
      puts
    end
    puts Rainbow("  a b c d e f g h ").bright

    display_extra_board_message(board_message, winner_color) unless board_message == 0
  end

  def display_extra_board_message(board_message = 0, winner_color = nil)
    case board_message
    when "move not valid"
      display_move_not_valid_message
    when "illegal"
      display_illegal_message
    when "causes check"
      display_under_check_message
    when "en passant"
      display_en_passant_message
    when "stalemate"
      display_stalemate_message
    when "checkmate"
      display_checkmate_message(winner_color)
    end
  end

  def display_main_menu_reminder
    clear_screen
    puts "Remember that you'll be able to go back to"
    puts "the main menu at any time by typing in 'main menu'!"
    puts "Have fun :D"
    display_continue_prompt
  end

  def display_main_menu_error
    puts "Please enter 'new', 'delete', or 'load'!"
  end

  def display_move_not_valid_message
    print_skyblue("Please input a valid move!", true)
  end

  def display_under_check_message
    print_skyblue("You can't move that piece! That leads to a check!", true)
  end

  def display_illegal_message
    print_skyblue("That's an illegal move, try again!", true)
  end

  def display_king_under_check_message
    print_skyblue("Can't move, your king is under check!", true)
  end

  def display_en_passant_message
    print_skyblue("Duh, of course I coded in ")
    print Rainbow("en passant").skyblue.italic + " ;)"
  end

  def display_stalemate_message
    print_skyblue("OMG, there was a ")
    puts Rainbow("stalemate! ").skyblue.bright
    print_skyblue("Nobody wins.")
  end

  def display_checkmate_message(winner_color)
    print_skyblue("Checkmate! #{winner_color.capitalize} wins!")
  end

  def display_max_saves_message
    puts "Can't start a new game, max save amount reached (8)."
  end

  def display_final_message
    clear_screen
    final_message = <<~HEREDOC
      Thank you so much for playing, I hope
      you enjoyed the game!
    HEREDOC
    print_skyblue(final_message)
    print_skyblue("Made by ")
    print Rainbow("Dostendite").royalblue.bright
    puts
    display_end_prompt
  end

  def display_promotion_prompt
    print_skyblue("Input piece to promote your pawn to...", true)
    puts Rainbow("Queen / Rook / Bishop / Knight").gray.bright
  end

  def display_load_prompt
    puts "Enter save number to load..."
  end

  def display_delete_prompt
    puts "Input save number to delete..."
  end

  def display_multiple_move_choice(pieces_in_range)
    puts "Found #{pieces_in_range.length} in range."
    pieces_in_range.each_with_index do |piece, idx|
      position_algebraic = translate_to_algebraic(piece.position[0], piece.position[1])
      puts "#{idx + 1} -> #{piece.class} at #{position_algebraic}"
    end
    puts "Please input the index of the piece you want to move..."
  end

  def display_move_prompt(current_turn)
    print_skyblue("[#{current_turn}] ")
    print "Input your move coordinate...\n"
    puts "E.g.: " + Rainbow("Nf3 -> Knight to f3").gray.italic
  end

  def display_continue_prompt
    puts
    print Rainbow("Press any button to continue... ").italic
    gets
  end

  def display_end_prompt
    puts
    print Rainbow("Press any button to end... ").italic
    gets
  end

  def clear_screen
    # cls on windows?
    puts
    system("clear")
  end

  def print_skyblue(str, add_line = false)
    if add_line
      puts Rainbow(str).skyblue.bright
    else
      print Rainbow(str).skyblue.bright
    end
  end
end