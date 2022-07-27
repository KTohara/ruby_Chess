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

  def valid_moves(grid, last_move)
    reset_moves
    single_jump(grid)
    double_jump(grid)
    captures(grid)
    en_passant_capture(grid, last_move)
    # moves.values.flatten(1)
  end

  def single_jump(grid)
    move = [row + pawn_direction, col]
    piece = grid[row + pawn_direction][col]
    moves[:moves] << move if valid_location?(move) && empty_location?(piece)
  end

  def double_jump(grid)
    return if jump_blocked?(grid)

    double_jump_row = row + (pawn_direction * 2)
    move = [double_jump_row, col]
    piece_two_ahead = grid[double_jump_row][col]
    moves[:moves] << move if empty_location?(piece_two_ahead)
  end

  def jump_blocked?(grid)
    piece_one_ahead = grid[row + pawn_direction][col]
    moved || !empty_location?(piece_one_ahead)
  end

  def captures(grid)
    [-1, 1].each do |capture_direction|
      cx = row + pawn_direction
      cy = col + capture_direction
      capture_pos = [cx, cy]
      piece = grid[cx][cy]
      moves[:captures] << capture_pos if valid_location?(capture_pos) && enemy?(piece)
    end
  end

  def en_passant_capture(grid, last_move)
    return unless [3, 4].include?(row)

    en_passant_dir.each do |dx, dy|
      dx += row
      dy += col
      enemy_pos = [dx, dy]
      end_pos = [dx + pawn_direction, dy]
      next unless valid_location?(enemy_pos) && valid_en_passant?(grid, enemy_pos, end_pos, last_move)

      moves[:en_passant] << end_pos
    end
  end

  def update_en_passant(grid)
    en_passant_dir.each do |dx, dy|
      dx += row
      dy += col
      enemy_pos = [dx, dy]
      enemy = grid[dx][dy]
      next unless valid_location?(enemy_pos) && enemy.instance_of?(Pawn) && enemy?(enemy)

      enemy.en_passant = true if first_move_double_jump?
    end
  end

  def en_passant_enemy_pos(pos)
    ex, ey = pos
    [ex - pawn_direction, ey]
  end

  private

  def en_passant_dir
    EN_PASSANT_DIR
  end

  def pawn_direction
    color == :white ? -1 : 1
  end

  def valid_en_passant?(grid, enemy_pos, end_pos, last_move)
    return false unless enemy_pos == last_move

    enemy_pawn = grid[enemy_pos[0]][enemy_pos[1]]
    end_location = grid[end_pos[0]][end_pos[1]]
    return false unless empty_location?(end_location)

    enemy?(enemy_pawn) && en_passant
  end

  def first_move_double_jump?
    moved == false && [1, 6].include?(row - (pawn_direction * 2))
  end
end
