require_relative "lib/chess"
require_relative "lib/board"
require_relative "lib/square"
require_relative "lib/display"
require_relative "lib/serializer"

require_relative "lib/pieces/piece.rb"
require_relative "lib/pieces/pawn.rb"
require_relative "lib/pieces/knight.rb"
require_relative "lib/pieces/bishop.rb"
require_relative "lib/pieces/rook.rb"
require_relative "lib/pieces/queen.rb"
require_relative "lib/pieces/king.rb"

# remember to use bundle exec ruby main.rb!
# and bin/rspec for tests

chess = Chess.new
chess.introduce_player
chess.play_menu