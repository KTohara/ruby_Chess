# frozen_string_literal: true

require_relative 'piece'

# Pawn logic
class Pawn < Piece
  ADJACENT_DIRS = [[0, -1], [0, 1]].freeze

  attr_accessor :en_passant

  def initialize(color, pos)
    @en_passant = false
    super
  end

  def symbol
    color == :white ? '♙' : '♟'
  end

  # updates @moves hash
  def update_moves(grid, last_move)
    reset_moves
    single_jump(grid)
    double_jump(grid)
    captures(grid)
    en_passant_capture(grid, last_move)
  end

  # adds a move to @moves if the single jump is empty and within bounds of grid
  def single_jump(grid)
    move = [row + pawn_direction, col]

    add_move(move) if valid_location?(move) && piece_one_ahead(grid).empty?
  end

  # adds a move to @moves if any space between double jump is not blocked, or pawn has not moved
  def double_jump(grid)
    move = [row + (pawn_direction * 2), col]
    return unless valid_location?(move)

    add_move(move) unless double_jump_blocked?(grid) || moved
  end

  # iterates through capture diagonals
  # adds capture to @moves if within bounds of grid and piece to be captured is an enemy
  def captures(grid)
    [-1, 1].each do |capture_direction|
      cx = row + pawn_direction
      cy = col + capture_direction
      capture_pos = [cx, cy]
      capture_piece = grid[cx][cy]

      add_capture(capture_pos) if valid_location?(capture_pos) && enemy?(capture_piece)
    end
  end

  # early return if pawn row is not 3 or 4
  # iterates through adjacent positions of the pawn,
  # adds en passant capture to @moves if within bounds of grid and is a valid en passant
  def en_passant_capture(grid, last_move)
    return unless [3, 4].include?(row)

    ADJACENT_DIRS.each do |dx, dy|
      dx += row
      dy += col
      enemy_pos = [dx, dy]
      end_pos = [dx + pawn_direction, dy]
      next unless valid_location?(enemy_pos) && valid_en_passant?(grid, enemy_pos, end_pos, last_move)

      add_en_passant(end_pos)
    end
  end

  # checks adjacent pieces of the pawn if the piece is within bounds of the grid and is an enemy pawn
  # toggles en passant on enemy piece if the piece has double jumped as its first move
  def update_en_passant(grid)
    ADJACENT_DIRS.each do |dx, dy|
      dx += row
      dy += col
      piece_pos = [dx, dy]
      piece = grid[dx][dy]
      next unless valid_location?(piece_pos) && piece.instance_of?(Pawn) && enemy?(piece)

      piece.en_passant = true if first_move_double_jump?
    end
  end

  # returns the position above or below the enemy piece
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

  # determines the row direction depending on piece color
  def pawn_direction
    color == :white ? -1 : 1
  end

  # early return false if enemy position is not the last move or ending position is not empty
  # return true if the adjacent pawn position is an enemy, and pawn itself has @en_passant triggered
  def valid_en_passant?(grid, enemy_pos, end_pos, last_move)
    enemy_pawn = grid[enemy_pos[0]][enemy_pos[1]]
    end_location = grid[end_pos[0]][end_pos[1]]
    return false if enemy_pos != last_move || !end_location.empty?

    enemy?(enemy_pawn) && en_passant
  end

  # returns true if the two positions ahead of the pawn is not empty
  def double_jump_blocked?(grid)
    !piece_one_ahead(grid).empty? || !piece_two_ahead(grid).empty?
  end

  # returns the piece one position ahead of the pawn
  def piece_one_ahead(grid)
    grid[row + pawn_direction][col]
  end

  # returns the piece two positions ahead of the pawn
  def piece_two_ahead(grid)
    grid[row + (pawn_direction * 2)][col]
  end

  # sidenote: method is called BEFORE @moved is updated, but AFTER positions has been updated
  # to prevent potentially triggering if pawn has made two single jumps
  def first_move_double_jump?
    moved == false && [1, 6].include?(row - (pawn_direction * 2))
  end

  def add_en_passant(ep_pos)
    moves[:en_passant] << ep_pos
  end
end
