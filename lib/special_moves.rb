# frozen_string_literal: true

# Board methods for special rules
module SpecialMoves
  def en_passant_move(piece, end_pos)
    self[piece.en_passant_enemy_pos(end_pos)] = NullPiece.new
  end

  def castling_move(end_pos)
    row, col = end_pos
    old_rook_pos, new_rook_pos = col == 6 ? king_castle(row) : queen_castle(row)
    rook_piece = self[old_rook_pos]
    self[new_rook_pos] = rook_piece
    self[old_rook_pos] = NullPiece.new
  end

  def check?(turn_color)
    update_all_moves
    enemy_pieces(turn_color).any? do |piece|
      piece.list_all_captures.include?(king_pos(turn_color))
    end
  end

  def checkmate?(turn_color)
    return false unless check?(turn_color)

    ally_pieces(turn_color).none? do |piece|
      moves = piece.list_all_moves
      moves.any? { |move| !in_check?(turn_color, piece.pos, move) }
    end
  end

  def in_check?(turn_color, start_pos, end_pos)
    undo_piece = self[end_pos]
    test_move(start_pos, end_pos)
    check_status = check?(turn_color)
    undo_move(end_pos, start_pos, undo_piece)
    update_all_moves
    check_status
  end

  private

  def king_castle(row)
    old_rook_col = 7
    new_rook_col = 5
    [[row, old_rook_col], [row, new_rook_col]]
  end

  def queen_castle(row)
    old_rook_col = 0
    new_rook_col = 3
    [[row, old_rook_col], [row, new_rook_col]]
  end

  def pieces
    grid.flatten.reject(&:empty?)
  end

  def enemy_pieces(turn_color)
    pieces.reject { |piece| piece.color == turn_color }
  end

  def ally_pieces(turn_color)
    pieces.select { |piece| piece.color == turn_color }
  end

  def test_move(start_pos, end_pos)
    piece = self[start_pos]
    self[end_pos] = piece
    piece.pos = end_pos
    self[start_pos] = NullPiece.new
  end

  def undo_move(end_pos, start_pos, undo_piece)
    piece = self[end_pos]
    piece.pos = start_pos
    self[start_pos] = piece
    self[end_pos] = undo_piece
  end

  def king_pos(turn_color)
    ally_pieces(turn_color).find { |piece| piece.instance_of?(King) }.pos
  end

  def update_all_moves
    pieces.each { |piece| piece.update_moves(grid, last_move) }
  end
end
