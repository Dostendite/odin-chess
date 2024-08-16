# maybe use msgpack?
# https://www.sitepoint.com/choosing-right-serialization-format/

# serializer module
# -- job is to serialize the game state & position of the pieces
# -- in order to provide a save system
module Serializer
  @@save_capacity = 8
  @@save_amount = 0

  def self.get_save_amount
    @@save_amount
  end

  def self.update_save_amount(amount)
    @@save_amount += amount
  end

  def create_save
    serialized_board = serialize_board
    # check for last save & store
    # with 1 index higher
    # e.g.: "chess_save_7"
    update_save_amount(+1)
  end

  def load_save(number)
    deserialized_board = deserialize_board
    # e.g.: number = 7
    # loads "chess_save_7"
  end

  def delete_save
    update_save_amount(-1)
  end

  def serialize_board(board); end
  def deserialize_board(); end
end

Serializer.update_save_amount(+3)