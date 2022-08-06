# frozen_string_literal: true

require 'yaml'

# Methods for saving or loading a game
module SaveLoad
  def save_game
    Dir.mkdir('save_states') unless Dir.exist?('save_states')

    save_file = YAML.dump(self)
    file_name = "chess_save#{Time.now.to_i}"
    File.write("save_states/#{file_name}.yaml", save_file)
    puts "Game saved in 'saves/#{file_name}'"
    exit(0)
  end

  def load_game
    unless load_exists?
      puts "No saves found\nExiting... "
      exit(0)
    end
    load_file = show_load_files
    load_data = File.read("./save_states/#{load_file}")
    YAML.load(load_data)
    File.delete("./save_states/#{save_file}")
  end

  def load_exists?
    return false if !Dir.exist?('./save_states') || Dir.empty?('./save_states')

    true
  end

  def show_load_files
    files = Dir.children('./save_states')
    file_index = files.map.with_index { |file_name, i| "#{[i + 1]} #{file_name.chomp('.yaml')}" }
    input = validate_load_game(file_index)
    files[input - 1]
  end

  def validate_load_game(file_index)
    file_index.each { |save| puts save }
    index_list = (1..file_index.length).to_a
    input = nil
    until index_list.include?(input)
      puts "\nChoose a file to load"
      input = gets.chomp.to_i
    end
    input
  end
end
