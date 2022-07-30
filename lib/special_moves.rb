# frozen_string_literal: true

# Board methods for special rules
module SpecialMoves
  private

  # returns all pieces on the board (white and black, no null)
  def pieces
    grid.flatten.reject(&:empty?)
  end

  # returns all pieces that are enemy to the given color
  def enemy_pieces(turn_color)
    pieces.reject { |piece| piece.color == turn_color }
  end

  # returns all pieces that are allies to the given color
  def ally_pieces(turn_color)
    pieces.select { |piece| piece.color == turn_color }
  end

  # en passant methods
  def en_passant_move(piece, end_pos)
    self[piece.en_passant_enemy_pos(end_pos)] = NullPiece.new
  end

  # castling methods
  def castling_move(end_pos)
    row, col = end_pos
    old_rook_pos, new_rook_pos = col == 6 ? king_castle(row) : queen_castle(row)
    rook_piece = self[old_rook_pos]
    self[new_rook_pos] = rook_piece
    self[old_rook_pos] = NullPiece.new
    rook_piece.update(new_rook_pos, grid)
  end

  # returns the rook positions for king side castling
  def king_castle(row)
    old_rook_col = 7
    new_rook_col = 5
    [[row, old_rook_col], [row, new_rook_col]]
  end

  # returns the rook positions for queen side castling
  def queen_castle(row)
    old_rook_col = 0
    new_rook_col = 3
    [[row, old_rook_col], [row, new_rook_col]]
  end

  # tests a move to see if it causes a king to be in check
  def move_causes_check?(turn_color, start_pos, end_pos)
    undo_piece = self[end_pos]
    test_move(start_pos, end_pos)
    check_status = check?(turn_color)
    undo_move(end_pos, start_pos, undo_piece)
    update_all_moves
    check_status
  end

  # moves a piece, and places a null piece in it's place
  def test_move(start_pos, end_pos)
    piece = self[start_pos]
    self[end_pos] = piece
    piece.pos = end_pos
    self[start_pos] = NullPiece.new
  end

  # moves the piece back to it's starting position, and places the original piece back in it's place
  def undo_move(end_pos, start_pos, undo_piece)
    piece = self[end_pos]
    self[start_pos] = piece
    piece.pos = start_pos
    self[end_pos] = undo_piece
  end

  # finds the position of the given color's king
  def king_pos(turn_color)
    ally_pieces(turn_color).find { |piece| piece.instance_of?(King) }.pos
  end

  # updates moves for all pieces on the board
  def update_all_moves
    pieces.each { |piece| piece.update_moves(grid, last_move) }
  end

  # pawn promotion prompt
  def promote_pawn(input, color, end_pos)
    piece = case input
      when 1 then Rook.new(color, end_pos)
      when 2 then Knight.new(color, end_pos)
      when 3 then Bishop.new(color, end_pos)
      when 4 then Queen.new(color, end_pos)
    end
    self[end_pos] = piece
  end
end
