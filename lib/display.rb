# frozen_string_literal: true

require_relative 'cursor'
require_relative 'colors'

# Board render logic
class Display
  include Colors

  COLUMN_LETTERS = ('a'..'h').to_a.freeze

  attr_reader :board, :cursor, :notifications

  def initialize
    @cursor = Cursor.new([7, 0])
    @notifications = {}
  end

  def render(grid, selected = nil)
    system('clear')
    puts display_board(grid, selected)
    display_notification
  end

  def display_board(grid, selected = nil)
    rows = map_board_rows(grid, selected).join("\n")
    "#{rows}\n   #{color_string(COLUMN_LETTERS.join('  '))} "
  end

  def map_board_rows(grid, selected = nil)
    grid.map.with_index do |row, index|
      row_num = 8 - index
      "#{color_string(row_num)} #{map_board_pieces(row, index, selected).join}"
    end
  end

  def map_board_pieces(row, pos_x, selected = nil)
    row.map.with_index do |piece, pos_y|
      pos = [pos_x, pos_y]
      foreground = fore_color(piece, pos, selected)
      background = back_color(pos)
      symbol = map_symbol(piece, pos, selected)
      color_piece(foreground, background, symbol)
    end
  end

  # colors the piece's foreground and background
  def color_piece(foreground, background, string)
    "\e[#{foreground};48;5;#{background}m#{string}\e[0m"
  end

  # colors a string into light_blue
  def color_string(string)
    "\e[1;34m#{string}\e[0m"
  end

  # changes the color of the piece depending on circumstance
  def fore_color(piece, pos, selected = nil)
    return COLORS[piece.color] unless cursor.selected

    if selected.moves[:moves].include?(pos) || selected.moves[:castling].include?(pos)
      COLORS[:red]
    elsif selected.moves[:captures].include?(pos) || selected.moves[:en_passant].include?(pos)
      COLORS[:green]
    else
      COLORS[piece.color]
    end
  end

  # changes the background color depending on circumstance
  def back_color(pos)
    if cursor.cursor_pos == pos && cursor.selected
      BG_COLORS[:light_orange]
    elsif cursor.cursor_pos == pos
      BG_COLORS[:light_blue]
    elsif (pos[0] + pos[1]).odd?
      BG_COLORS[:black]
    else
      BG_COLORS[:white]
    end
  end

  # changes the symbol into a circle if the position is a valid move
  def map_symbol(piece, pos, selected = nil)
    return piece.to_s unless cursor.selected

    selected_moves = selected.list_all_moves
    selected_moves.include?(pos) ? '░●░' : piece.to_s
  end

  def display_notification
    notifications.each_value { |error| puts error }
  end

  def reset_notifications
    notifications.delete(:error)
  end
end
