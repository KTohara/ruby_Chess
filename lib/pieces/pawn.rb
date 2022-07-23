# frozen_string_literal: true

require_relative 'piece'

# Pawn logic
class Pawn < Piece
  EN_PASSANT_DIR = [[0, -1], [0, 1]].freeze

  attr_reader :en_passant

  def initialize(color, pos)
    @en_passant = false
    super
  end

  def symbol
    color == :white ? '♙' : '♟'
  end

  def valid_moves(board)
    [
      single_jump(board.grid),
      double_jump(board.grid),
      captures(board.grid),
      en_passant_capture(board.grid, board.last_move)
    ]
      .compact
      .reject(&:empty?)
  end

  def single_jump(grid)
    row, col = pos
    move = [row + pawn_direction, col]
    return unless valid_location?(move)

    piece = grid[row + pawn_direction][col]
    move if empty_location?(piece)
  end

  def double_jump(grid)
    row, col = pos
    piece_one_ahead = grid[row + pawn_direction][col]
    return if moved || !empty_location?(piece_one_ahead)

    double_row = row + (pawn_direction * 2)
    piece_two_ahead = grid[double_row][col]
    [double_row, col] if empty_location?(piece_two_ahead)
  end

  def captures(grid)
    [-1, 1].each_with_object([]) do |capture_direction, moves|
      cx = row + pawn_direction
      cy = col + capture_direction
      capture_move = [cx, cy]
      next unless valid_location?(capture_move)

      piece = grid[cx][cy]
      moves << capture_move if enemy?(piece)
    end
  end

  def en_passant_capture(grid, last_move)
    return unless [3, 4].include?(row)

    en_passant_dir.each_with_object([]) do |dir, moves|
      dx, dy = dir
      dx += row
      dy += col
      enemy_pos = [dx, dy]
      end_pos = [dx + pawn_direction, dy]
      moves << end_pos if valid_en_passant?(grid, enemy_pos, end_pos, last_move)
    end
  end

  def update_en_passant(grid)
    en_passant_dir.each do |move|
      row, col = move
      piece = grid[row][col]
      next unless valid_location?(move) && piece.instance_of?(Pawn)

      piece.en_passant = first_move_double_jump?
    end
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
    return false unless valid_location?(end_pos) && empty_location?(end_location)

    enemy?(enemy_pawn) && en_passant
  end

  def first_move_double_jump?
    moved == false && [1, 6].include?(piece.row - (pawn_direction * 2))
  end
end
