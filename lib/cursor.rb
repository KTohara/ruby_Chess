# frozen_string_literal: true

require 'io/console'

KEYMAP = {
  ' ' => :space,
  'h' => :left,
  'j' => :down,
  'k' => :up,
  'l' => :right,
  'w' => :up,
  'a' => :left,
  's' => :save,
  'd' => :right,
  "\t" => :tab,
  "\r" => :return,
  "\n" => :newline,
  "\e" => :escape,
  "\e[A" => :up,
  "\e[B" => :down,
  "\e[C" => :right,
  "\e[D" => :left,
  "\177" => :backspace,
  "\004" => :delete,
  "\u0003" => :ctrl_c,
  "\u0013" => :ctrl_s
}.freeze

MOVES = {
  left: [0, -1],
  right: [0, 1],
  up: [-1, 0],
  down: [1, 0]
}.freeze

# STDIN cursor logic
class Cursor
  attr_reader :cursor_pos, :board, :selected

  def initialize(cursor_pos, board)
    @cursor_pos = cursor_pos
    @board = board
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
    # stops the console from printing return values
    $stdin.echo = false

    # in raw mode data is given as is to the program--the system
    # doesn't preprocess special characters such as control-c
    $stdin.raw!

    # STDIN.getc reads a one-character string as a numeric keycode.
    # chr returns a string of the character represented by the keycode.
    # (e.g. 65.chr => "A")
    input = $stdin.getc.chr

    if input == "\e"
      # read_nonblock(maxlen) reads at most maxlen bytes from a data stream;
      # it's nonblocking, meaning the method executes asynchronously;
      # it raises an error if no data is available, hence the need for rescue
      begin
        input << $stdin.read_nonblock(3)
      rescue StandardError
        nil
      end
      begin
        input << $stdin.read_nonblock(2)
      rescue StandardError
        nil
      end
    end
    # the console prints return values again
    $stdin.echo = true
    # the opposite of raw mode
    $stdin.cooked!
    input
  end

  def handle_key(key)
    case key
    when :return, :space
      toggle_selected
      cursor_pos
    when :ctrl_c
      exit 0
    when :save
      save
    when :up, :down, :left, :right
      diff = MOVES[key]
      update_pos(diff)
      nil
    end
  end

  def update_pos(diff)
    row, col = cursor_pos
    dx, dy = diff
    new_pos = [row + dx, col + dy]
    @cursor_pos = new_pos if board.valid_pos?(new_pos)
  end

  def save
    raise 'saving'
  end
end
