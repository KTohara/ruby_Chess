# frozen_string_literal: true

require 'yaml'

# Methods for saving or loading a game
module SaveLoad
  def save_game(file_name = nil)
    Dir.mkdir('save_states') unless Dir.exist?('save_states')

    save_file = YAML.dump(self)
    date = Time.now.strftime('%b-%d-%Y').downcase
    hour = Time.now.strftime('%H:%M:%S')
    file_name ||= "save-#{date}-#{hour}"
    File.write("save_states/#{file_name}.yaml", save_file)
    puts "Game saved in 'saves/#{file_name}'"
    exit(0)
  end

  def load_game(load_file = nil)
    no_saves_warning unless load_exists?

    load_file ||= show_load_files
    load_data = File.read("./save_states/#{load_file}")
    game = YAML.safe_load(
      load_data,
      aliases: true,
      permitted_classes: [Symbol, Game, Board, Cursor, Player, King, Queen, Pawn, Rook, Bishop, Knight, NullPiece]
    )
    File.delete("./save_states/#{load_file}")
    game
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

  def no_saves_warning
    puts "No saves found\nExiting... "
    exit(0)
  end
end
