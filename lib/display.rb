# display module
# -- job is to display the main menu, as well as
# -- the chess game and its messages
module Display
  include Serializer

  def display_introduction
    clear_screen
    introduction = <<~HEREDOC
    Hello! Welcome to my very first game of Chess!
    This is the capstone project for 
    The Odin Project's Ruby course.
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
    end
  end

  def display_board(board)
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
  end

  def display_main_menu_reminder
    clear_screen
    puts "Remember that you'll be able to go back to"
    puts "the main menu at any time by typing in 'main menu'!"
    puts "Have fun :D"
    display_continue_prompt
  end

  def display_illegal_message
    puts "That's an illegal move, try again!"
    puts
  end

  def display_under_check_message
    puts "You can't move that piece! You're under check!"
    puts
  end

  def display_en_passant
    print "Duh, of course I coded in "
    print Rainbow("en passant").italic + " ;)"
    puts
  end

  def display_stalemate_message
    print "OMG, there was a "
    puts Rainbow("stalemate! ").bright + "Nobody wins."
    puts
  end

  def display_checkmate_message(winner_color = "Black")
    print {Rainbow("Checkmate! ").bright}
    puts "#{winner_color.capitalize} wins!"
  end

  def display_max_saves_message
    puts "Can't start a new game, max save amount reached (8)."
  end

  def display_final_message
    clear_screen
    final_message = <<~HEREDOC
      Thank you so much for playing, I hope
      you enjoyed the game!

      You will now be returned to the main menu.
    HEREDOC
    print_skyblue(final_message)
    display_continue_prompt
  end

  def display_promote_prompt
    puts "Input piece to promote your pawn to..."
    puts
  end

  def display_load_prompt
    puts "Enter save number to load..."
  end

  def display_delete_prompt
    puts "Input save number to delete..."
  end

  def display_move_prompt
    puts "Input your move coordinate...\n"
    puts "E.g.: " + Rainbow("Nf3 -> Knight to f3").gray.italic
    puts
  end

  def display_continue_prompt
    puts
    print Rainbow("Press any button to continue... ").italic
    gets
  end

  def clear_screen
    system("cls || clear")
  end

  def print_skyblue(str, add_line = false)
    if add_line
      puts Rainbow(str).skyblue.bright
    else
      print Rainbow(str).skyblue.bright
    end
  end
end