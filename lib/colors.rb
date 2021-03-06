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
      black: '0',
      white: '231',
      red: '160',
      green: '49',
      light_blue: '110',
      light_orange: '172'
    }.freeze

  def color(_color)
    {
      black: "\e[30m#{self}\e[0m",
      white: "\e[37m#{self}\e[0m",
      light_red: "\e[1;31m#{self}\e[0m",
      light_blue: "\e[1;34m#{self}\e[0m"
    }
  end
end
