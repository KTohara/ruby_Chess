# frozen_string_literal: true

require 'io/console'

KEYMAP = {
  ' ' => :space,
  's' => :s,
  'd' => :d,
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

  # converts the key press into a designated method
  def key_input(read_char = nil)
    key = KEYMAP[read_char]
    handle_key(key)
  end

  def toggle_selected
    @selected = !selected
  end

  private

  # returns user key press
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

  # return or space: returns the selected position of the cursor
  # ctrl c: exits the game
  # s: saves the game
  # d: resign the game
  # directions: updates the cursor by it's direction/move index
  def handle_key(key)
    case key
    when :return, :space
      toggle_selected
      cursor_pos
    when :ctrl_c
      exit(0)
    when :s
      :save
    when :d
      :resign
    when :up, :down, :left, :right
      pos_diff = MOVES[key]
      update_pos(pos_diff)
      nil
    end
  end

  # takes the index difference from MOVES hash, updates row/col of cursor position
  def update_pos(pos_diff)
    row, col = cursor_pos
    dx, dy = pos_diff
    new_pos = [row + dx, col + dy]
    @cursor_pos = new_pos if new_pos.all? { |axis| axis.between?(0, 7) }
  end

  # WIP
  def save
    raise 'saving'
  end

  # WIP
  def resign
    raise 'resign game'
  end
end
