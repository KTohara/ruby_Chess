# frozen_string_literal: true

require_relative 'colors'

# Handles all messages, prompts, notifications and exceptions
module Messages
  include Colors

  # error message when user selects an empty square on the board
  class SquareError < StandardError
    def message
      'Square is empty. Select an existing piece.'
    end
  end

  # error message when user selects an opponent's piece
  class OpponentError < StandardError
    def message
      'Piece belongs to the opponent. You must move your own pieces.'
    end
  end

  # error message when a piece cannot move to the given position
  class MoveError < StandardError
    def message
      'Piece cannot move here. Select a valid position.'
    end
  end

  # error message when user attempts to move a piece that puts it's king into check
  class CheckError < StandardError
    def message
      'Move puts king in check. Select another position'
    end
  end

  # error message when user attempts to move a piece out of bounds of the board (0 - 7)
  class PositionError < StandardError
    def message
      'Invalid Position'
    end
  end

  # displays all notifications
  def display_notifications
    notifications.each_value { |message| puts "\n#{message.light_red}" }
  end

  # displays all messages
  def display_messages
    messages.each_value { |message| puts message }
  end

  def display_intro_msg
    system('clear')
    puts <<~INTRO
      Let's play...

       ▄████▄   ▄█   █▄      ▄█████▄    ▄████▄   ▄████▄ ▀██▄
       ██▀  ██ ███   ███    ███  ▄█▀   ███  ███ ███  ███  ██▄
      ██   █▀  ▀██   ▀██    ██    ▀   ██    █▀ ██    █▀  ▄███
      ██    ▄▄▄███▄  ██▀   ▄██▄▄▄▄▄▄  ██▄      ██▄     ▀▀████▀
      ██      ▀███▀▀███▄ ▀▀▀███▀▀▀   ▀██████▄ ▀███████▄  ▀███
      ██    █▄ ██▀   ▀██▀▄  ██     ▄    ▄  ▀██    ▄  ▀██  ▄█▀
       ██▄  █▀ ██    ███  ▀ ███   ▀█  ▄█   ██▀  ▄█   ██▀ ▄▄▄
       ▀████▀  ▄█▄   █▀      ▀█████▀ ▄██████▀  ▄██████▀ ▀█▀
      
      INTRO
      .light_blue
    puts  <<~DIRECTIONS
      How to play:

      ARROW KEYS to move
      ENTER or SPACE to confirm selection
      B to backup save
      R to resign

    DIRECTIONS
  end

  def display_thanks_then_exit
    puts 'Thank you for playing!'.blue
    exit(0)
  end

  # resets all notifications
  def reset_notifications
    notifications.each_key { |key| notifications.delete(key) }
  end

  # resets all messages
  def reset_messages
    messages.each_key { |key| messages.delete(key) }
  end

  def add_check_notification
    notifications[:check] = "Player #{turn_color.capitalize}, King is in check!"
  end

  def add_checkmate_notification
    notifications[:checkmate] = "Player #{turn_color.capitalize}, Checkmate!"
  end

  def add_draw_notification
    notifications[:draw] = 'Game is a draw!'
  end

  def add_notification_replay
    notifications[:replay] = "\nWould you like to play another game?\n\n[Y]es\n[N]o"
  end

  # adds pawn promotion message
  def add_msg_promotion
    messages[:promotion] =
      <<~PROMOTION
        Pawn promotion! Choose an option:

        [1] Rook
        [2] Knight
        [3] Bishop
        [4] Queen
      PROMOTION
  end

  def add_msg_en_passant(piece)
    messages[:en_passant] = "En passant was made by #{piece.color} #{piece.class}!"
  end

  def add_msg_castling(piece)
    messages[:castling] = "Castling move was made by #{piece.color} #{piece.class}!"
  end

  def add_msg_choose_start
    messages[:choose_start] = "Player: #{turn_color.to_s.capitalize}, choose a piece to move!"
  end

  def add_msg_choose_end
    messages[:choose_end] = "Player: #{turn_color.to_s.capitalize}, move your piece!"
  end

  def add_msg_resign_game
    messages[:resign] = "\nResign game?\n\n[Y]es\n[N]o"
  end

  def prompt_game_type
    puts "[1] Play new game\n[2] Load game\n"
    gets.chomp.to_i
  end

  # prompts user for a starting position, updates key input until enter/space key is pressed
  def prompt_start_pos(start_pos = nil)
    until start_pos
      add_msg_choose_start
      render(board.grid)
      start_pos = cursor.key_input
    end
    reset_notifications
    reset_messages
    start_pos
  end

  # prompts user for a ending position, updates key input until enter/space key is pressed
  def prompt_end_pos(start_pos, end_pos = nil)
    until end_pos
      piece = board[start_pos]
      piece.update_moves(board.grid, board.last_move) # needed for mapping moves
      add_msg_choose_end
      render(board.grid, piece)
      # p piece.moves # use to debug
      # p board[start_pos] # use to debug
      end_pos = cursor.key_input
    end
    reset_notifications
    reset_messages
    end_pos
  end

  # prompts user for promotion option (rook, knight, bishop, queen)
  def prompt_promotion
    render(board.grid)
    input = gets.chomp.to_i
    input_options = [1, 2, 3, 4]
    validate_input(input, input_options)
  end

  # adds messages to message hash, and returns input if move type is a pawn promotion
  def special_move_msg(special_move, start_pos)
    piece = board[start_pos]
    case special_move
    when :en_passant
      add_msg_en_passant(piece)
      render(board.grid)
    when :castling
      add_msg_castling(piece)
      render(board.grid)
    when :promotion
      add_msg_promotion
      input = prompt_promotion
    end
    input
  end

  # prompts for input, loops until 'y' or 'n'
  def prompt_yes_no
    input = gets.chomp.downcase
    input_options = %w[y n]
    validate_input(input, input_options)
  end

  # loops until input is a part of the input options then returns input
  def validate_input(input, input_options)
    until input_options.include?(input)
      render(board.grid)
      input = gets.chomp.to_i if input_options.all?(Integer)
      input = gets.chomp.downcase if input_options.all?(String)
    end
    reset_messages
    input
  end
end
