# display module
# -- job is to display the main menu, as well as
# -- the chess game and its messages
module Display
  def display_introduction
    introduction_message = <<-HEREDOC
    Hello! Welcome to my very first game of Chess!

    It was made as a project for The Odin Project.

    Press any key to continue..."
    HEREDOC
    clear_screen
    print introduction_message
    prompt_continue
  end

  def display_main_menu
    clear_screen
  end

  def self.print_board(board)
    board.each_with_index do |row, index|
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

  def display_color_prompt; end
  def display_move_prompt; end
  def display_checkmate_message; end

  def display_final_message
    clear_screen
  end

  def prompt_continue
    puts "Press any button to continue..."
    gets
  end

  def clear_screen
    system("cls || clear")
  end
end