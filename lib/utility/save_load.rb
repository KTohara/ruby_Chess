# frozen_string_literal: true
require 'yaml'

# Methods for saving or loading a game
module SaveLoad
  def save_game
    Dir.mkdir('saves') unless Dir.exist?('saves')
    
    save_file = YAML.dump(self)
    file_name = "chess_save#{Time.now.to_i.to_s}"
    File.open("save_states/#{file_name}.yaml", 'w') { |f| f.write(save_file) }
    puts "Game saved in 'saves/#{file_name}'"
    exit(0)
  end

  def load_game
    unless load_exists?
      puts "No saves found\nExiting... "
      exit(0)
    end
    save_file = prompt_load_file
    save_data = File.read("./save_states/#{save_file}")
    file = YAML.load(save_data)
    File.delete("./save_states/#{save_file}")
    file
  end

  def load_exists?
    if !Dir.exist?('./save_states') || Dir.empty?('./save_states')
      return false
    end
    true
  end

  def prompt_load_file
    files = Dir.children('./save_states')
    file_index = files.map.with_index { |file_name, i| "#{[i + 1].to_s} #{file_name.chomp('yaml')}" }
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
