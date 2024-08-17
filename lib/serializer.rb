SAVE_NAME = "chess_save_"
SAVE_DIRECTORY = "./saves/"

# serializer module
# -- job is to serialize the game state & position of the pieces
# -- in order to provide a save system
module Serializer
  @@save_capacity = 8
  @@save_amount = 0

  def self.update_save_amount
    count = Dir[File.join(SAVE_DIRECTORY, "**", "*")].count { |f| File.file?(f) }
    @@save_amount = count
  end

  def self.get_save_amount
    @@save_amount
  end

  def create_save(unserialized_board)
    serialized_board = serialize_board(unserialized_board)
    @@save_amount += 1
    File.write(get_new_save_path(serialized_board), serialized_board)
  end

  def load_save(save_number)
    serialized_board = File.read(get_existing_save_path(save_number).to_s)
    deserialize_board(serialized_board)
  end

  def update_save(unserialized_board, save_number)
    File.truncate(get_existing_save_path(save_number))
    serialized_board = serialize_board(unserialized_board)
    File.write(get_existing_save_path(serialized_board), serialized_board)
  end

  def delete_save(save_number)
    File.delete(get_existing_save_path(save_number))
  end

  # File.open(SAVE_DIRECTORY + SAVE_NAME + "#{@@save_amount}", "w") do |new_save|
  #   new_save.write(serialized_board)
  #   new_save.close
  # end

  # File.open(SAVE_DIRECTORY + SAVE_NAME + "#{save_number}", "r") do |save|
  #   File.delete(save)
  # end
  # @@save_amount -= 1
  
  def serialize_board(unserialized_board)
    Marshal.dump(unserialized_board)
  end
  
  def deserialize_board(serialized_board)
    Marshal.load(serialized_board)
  end

  private

  def get_new_save_path(save_number)
    SAVE_DIRECTORY + SAVE_NAME + @@save_amount.to_s
  end

  def get_existing_save_path(save_number)
    SAVE_DIRECTORY + SAVE_NAME + save_number.to_s
  end
end