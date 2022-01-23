# frozen_string_literal: true

# file management utils
module GameFileUtils
  STORAGE_DIR = Rails.public_path.join('games')

  # adds suffix .json to game id which serves as file name
  def fname_for(id)
    "#{fprefix(id)}.json"
  end

  def safe_read(fname)
    File.read(storage_path.join(fname))
  rescue StandardError
    file = File.open(storage_path.join(fname), w)
    file.close
    '{}'
  end

  def file_exists?(fname)
    file_path = storage_path.join(fname)
    File.exist? file_path
  end

  def delete_file(fname)
    file_path = storage_path.join(fname)
    File.delete(file_path)
  end

  def storage_path
    Dir.mkdir(STORAGE_DIR) unless File.directory? STORAGE_DIR
    STORAGE_DIR
  end

  def fprefix(id)
    "#{current_pin}-#{id}"
  end

  def operator_game_files
    Dir.glob(storage_path.join("#{current_pin}-*.json"))
  end

  def all_game_files
    Dir.glob(storage_path.join('*.json'))
  end
end
