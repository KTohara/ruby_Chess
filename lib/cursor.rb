# frozen_string_literal: true

require 'io/console'

KEYMAP = {
  ' ' => :space,
  's' => :save,
  'd' => :draw,
  "\t" => :tab,
  "\r" => :return,
  "\n" => :newline,
  "\e" => :escape,
  "\e[A" => :up,
  "\e[B" => :down,
  "\e[C" => :right,
  "\e[D" => :left,
  "\u0003" => :ctrl_c
}.freeze

MOVES = {
  left: [0, -1],
  right: [0, 1],
  up: [-1, 0],
  down: [1, 0]
}.freeze

# STDIN cursor logic
class Cursor
  attr_reader :cursor_pos, :board
  attr_accessor :selected

  def initialize(cursor_pos)
    @cursor_pos = cursor_pos
    @selected = false
  end

  def key_input
    key = KEYMAP[read_char]
    handle_key(key)
  end

  def toggle_selected
    @selected = !selected
  end

  private

  def read_char
    $stdin.echo = false
    $stdin.raw!
    input = $stdin.getc.chr

    if input == "\e"
      begin
        input << $stdin.read_nonblock(3)
      rescue StandardError
        nil
      end
    end
    $stdin.echo = true
    $stdin.cooked!
    input
  end

  def handle_key(key)
    case key
    when :return, :space
      toggle_selected
      cursor_pos
    when :ctrl_c
      exit(0)
    when :save
      save
    when :draw
      draw
    when :up, :down, :left, :right
      pos_diff = MOVES[key]
      update_pos(pos_diff)
      nil
    end
  end

  def update_pos(pos_diff)
    row, col = cursor_pos
    dx, dy = diff
    new_pos = [row + dx, col + dy]
    @cursor_pos = new_pos if new_pos.all? { |axis| axis.between?(0, 7) }
  end

  # WIP
  def save
    raise 'saving'
  end

  # WIP
  def draw
    raise 'draw game'
  end
end
