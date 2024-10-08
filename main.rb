require_relative "lib/chess"
require_relative "lib/board"
require_relative "lib/square"
require_relative "lib/display"
require_relative "lib/serializer"
require_relative "lib/move_validator"

require_relative "lib/pieces/piece.rb"
require_relative "lib/pieces/pawn.rb"
require_relative "lib/pieces/knight.rb"
require_relative "lib/pieces/bishop.rb"
require_relative "lib/pieces/rook.rb"
require_relative "lib/pieces/queen.rb"
require_relative "lib/pieces/king.rb"

chess = Chess.new
chess.play_chess