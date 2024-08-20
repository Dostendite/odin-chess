SAVE_NAME = "chess_save_"
SAVE_DIRECTORY = "./saves/"

# serializer module
# -- job is to serialize the game state & position of the pieces
# -- in order to provide a save system
module Serializer
  @@save_capacity = 8
  @@save_numbers = []

  def self.get_save_amount
    @@save_numbers.length
  end

  def self.get_save_numbers
    @@save_numbers
  end

  def self.update_save_numbers
    new_save_numbers = []
    Dir.entries(SAVE_DIRECTORY).grep(/\d$/).each do |save|
      new_save_numbers << save[-1]
    end
    @@save_numbers = new_save_numbers.map(&:to_i).sort
  end

  def create_save(unserialized_board)
    serialized_board = serialize_board(unserialized_board)
    File.write(get_new_save_path, serialized_board)
  end

  def load_save(save_number)
    serialized_board = File.read(get_existing_save_path(save_number).to_s)
    deserialize_board(serialized_board)
  end

  def update_save(unserialized_board, save_number)
    save_path = get_existing_save_path(save_number)
    serialized_board = serialize_board(unserialized_board)
    File.truncate(save_path, 0)
    File.write(save_path, serialized_board)
  end

  def get_missing_save_number
    return 1 if @@save_numbers.empty?

    @@save_numbers.each_index do |idx|
      return if @@save_numbers.length == (idx - 1)
      return 1 unless @@save_numbers.include?(1)

      next if (@@save_numbers[idx] + 1) == @@save_numbers[idx + 1]
      return (@@save_numbers[idx] + 1)
    end
  end
  
  def delete_save(save_number)
    File.delete(get_existing_save_path(save_number))
  end
  
  def serialize_board(unserialized_board)
    Marshal.dump(unserialized_board)
  end
  
  def deserialize_board(serialized_board)
    Marshal.load(serialized_board)
  end

  private

  def get_new_save_path
    new_save_number = get_missing_save_number
    SAVE_DIRECTORY + SAVE_NAME + new_save_number.to_s
  end

  def get_existing_save_path(save_number)
    SAVE_DIRECTORY + SAVE_NAME + save_number.to_s
  end
end