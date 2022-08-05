# frozen_string_literal: true

# Colors used for Display class
module Colors
  COLORS =
    {
      black: '30',
      white: '97',
      red: '31',
      green: '32'
    }.freeze

  BG_COLORS =
    {
      black: '189',
      white: '231',
      red: '160',
      green: '49',
      sky: '195',
      light_blue: '110',
      light_orange: '172'
    }.freeze
end

# rubocop:disable Style
# monkey-patched String class for colors
class String
  def black;      "\e[30m#{self}\e[0m"; end
  def white;      "\e[37m#{self}\e[0m"; end
  def blue;       "\e[94m#{self}\e[0m"; end
  def light_red;  "\e[1;31m#{self}\e[0m"; end
  def light_blue; "\e[1;34m#{self}\e[0m"; end
  def bold;       "\e[1m#{self}\e[22m" end
end
# rubocop:enable Style
