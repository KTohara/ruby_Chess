# frozen_string_literal: true

require_relative 'cursor'
require_relative 'colors'

# Board render logic
class Display
  include Colors

  COLUMN_LETTERS = ('a'..'h').to_a.freeze

  attr_reader :board, :cursor, :notifications

  def initialize(board)
    @board = board
    @cursor = Cursor.new([7, 0], board)
    @notifications = {}
  end

  def render
    system('clear')
    puts self
    notifications.each { |error| display_error(error) }
  end

  def to_s
    rows = map_board_rows.join("\n")
    "#{rows}\n   #{color_string(COLUMN_LETTERS.join('  '))} "
  end

  def map_board_rows
    board.grid.map.with_index do |row, index|
      row_num = 8 - index
      "#{color_string(row_num)} #{map_board_pieces(row, index).join}"
    end
  end

  def map_board_pieces(row, pos_x)
    row.map.with_index do |piece, pos_y|
      foreground = fore_color(piece)
      background = back_color(pos_x, pos_y)
      color_piece(foreground, background, piece.to_s)
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

  def fore_color(piece)
    COLORS[piece.color]
  end

  # changes the background color depending on the circumstance
  def back_color(pos_x, pos_y)
    if cursor.cursor_pos == [pos_x, pos_y] && cursor.selected
      BG_COLORS[:light_orange]
    elsif cursor.cursor_pos == [pos_x, pos_y]
      BG_COLORS[:light_blue]
    elsif (pos_x + pos_y).odd?
      BG_COLORS[:black]
    else
      BG_COLORS[:white]
    end
  end

  def display_error(_error)
    puts notifications[:error]
  end
end
