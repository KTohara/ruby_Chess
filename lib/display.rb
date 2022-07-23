# frozen_string_literal: true

require_relative 'cursor'
require_relative 'colors'

class Display
  include Colors

  COLUMN_LETTERS = ('a'..'h').to_a.freeze

  attr_reader :board, :cursor

  def initialize(board)
    @board = board
    @cursor = Cursor.new([7, 0], board)
  end

  def to_s
    rows = board_render.join("\n")
    "#{rows}\n   #{color_string(COLUMN_LETTERS.join('  '))} "
  end

  def board_render
    board.grid.map.with_index do |row, index|
      row_num = 8 - index
      "#{color_string(row_num)} #{board_row(row, index).join}"
    end
  end

  def board_row(row, pos_x)
    row.map.with_index do |piece, pos_y|
      foreground = fore_color(piece)
      background = back_color(pos_x, pos_y)
      color_piece(foreground, background, piece.to_s)
    end
  end

  def color_piece(foreground, background, string)
    "\e[#{foreground};48;5;#{background}m#{string}\e[0m"
  end

  def color_string(string)
    "\e[1;34m#{string}\e[0m"
  end

  def fore_color(piece)
    COLORS[piece.color]
  end

  def back_color(pos_x, pos_y)
    if cursor.cursor_pos == [pos_x, pos_y]
      BG_COLORS[:light_blue]
    elsif (pos_x + pos_y).odd?
      BG_COLORS[:black]
    else
      BG_COLORS[:white]
    end
  end
end
