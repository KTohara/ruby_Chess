# frozen_string_literal: true

require_relative 'piece'

# Pawn logic
class Pawn < Piece
  EN_PASSANT_DIR = [[0, -1], [0, 1]].freeze

  attr_accessor :en_passant

  def initialize(color, pos)
    @en_passant = false
    super
  end

  def symbol
    color == :white ? '♙' : '♟'
  end

  def update_moves(grid, last_move)
    reset_moves
    single_jump(grid)
    double_jump(grid)
    captures(grid)
    en_passant_capture(grid, last_move)
  end

  def single_jump(grid)
    move = [row + pawn_direction, col]
    piece = grid[row + pawn_direction][col]
    add_move(move) if valid_location?(move) && piece.empty?
  end

  def double_jump(grid)
    return if jump_blocked?(grid)

    double_jump_row = row + (pawn_direction * 2)
    move = [double_jump_row, col]
    piece_two_ahead = grid[double_jump_row][col]
    add_move(move) if piece_two_ahead.empty?
  end

  def captures(grid)
    [-1, 1].each do |capture_direction|
      cx = row + pawn_direction
      cy = col + capture_direction
      capture_pos = [cx, cy]
      piece = grid[cx][cy]
      add_capture(capture_pos) if valid_location?(capture_pos) && enemy?(piece)
    end
  end

  def en_passant_capture(grid, last_move)
    return unless [3, 4].include?(row)

    EN_PASSANT_DIR.each do |dx, dy|
      dx += row
      dy += col
      enemy_pos = [dx, dy]
      end_pos = [dx + pawn_direction, dy]
      next unless valid_location?(enemy_pos) && valid_en_passant?(grid, enemy_pos, end_pos, last_move)

      add_en_passant(end_pos)
    end
  end

  def update_en_passant(grid)
    EN_PASSANT_DIR.each do |dx, dy|
      dx += row
      dy += col
      piece_pos = [dx, dy]
      piece = grid[dx][dy]
      next unless valid_location?(piece_pos) && piece.instance_of?(Pawn) && enemy?(piece)

      piece.en_passant = true if first_move_double_jump?
    end
  end

  def en_passant_enemy_pos(enemy_pos)
    ex, ey = enemy_pos
    [ex - pawn_direction, ey]
  end

  # checks if pawn and can be promoted
  def promotable?
    promotion_row = color == :white ? 0 : 7
    row + pawn_direction == promotion_row
  end

  private

  def pawn_direction
    color == :white ? -1 : 1
  end

  def valid_en_passant?(grid, enemy_pos, end_pos, last_move)
    return false unless enemy_pos == last_move

    enemy_pawn = grid[enemy_pos[0]][enemy_pos[1]]
    end_location = grid[end_pos[0]][end_pos[1]]
    return false unless end_location.empty?

    enemy?(enemy_pawn) && en_passant
  end

  def jump_blocked?(grid)
    piece_one_ahead = grid[row + pawn_direction][col]
    moved || !piece_one_ahead.empty?
  end

  def first_move_double_jump?
    moved == false && [1, 6].include?(row - (pawn_direction * 2))
  end

  def add_en_passant(ep_pos)
    moves[:en_passant] << ep_pos
  end
end
