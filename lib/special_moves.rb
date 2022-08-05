# frozen_string_literal: true

# Handles board conditionals for specific piece special moves
module SpecialMoves
  # returns the type of special move
  def special_move_type(start_pos, end_pos)
    piece = self[start_pos]
    if en_passant_move?(piece, end_pos)
      :en_passant
    elsif castling_move?(piece, end_pos)
      :castling
    elsif promotion_move?(piece)
      :promotion
    end
  end

  # returns boolean if piece can perform en passant
  def en_passant_move?(piece, end_pos)
    piece.moves[:en_passant].include?(end_pos)
  end

  # returns boolean if piece can castle
  def castling_move?(piece, end_pos)
    piece.moves[:castling].include?(end_pos)
  end

  # returns boolean if piece can be promoted
  def promotion_move?(piece)
    piece.instance_of?(Pawn) && piece.promotable?
  end

  # calls special move method depending on type of move
  def execute_special_move(special_move, start_pos, end_pos, input = nil)
    start_piece = self[start_pos]
    case special_move
    when :en_passant then en_passant_move(start_piece, end_pos)
    when :castling then castling_move(end_pos)
    when :promotion then promotion_move(start_piece, input)
    end
  end

  # places a null piece at the enemy pawn's position
  def en_passant_move(piece, end_pos)
    self[piece.en_passant_enemy_pos(end_pos)] = NullPiece.new
  end

  # places null piece in rook's former position, and places rook in caslting position
  def castling_move(end_pos)
    row, col = end_pos
    old_rook_pos, new_rook_pos = col == 6 ? king_castle(row) : queen_castle(row)
    rook_piece = self[old_rook_pos]
    self[new_rook_pos] = rook_piece
    self[old_rook_pos] = NullPiece.new
    rook_piece.update(new_rook_pos, grid)
  end

  # replaces pawn with selected promotion piece
  def promotion_move(piece, input = nil)
    piece = case input
            when 1 then Rook.new(piece.color, piece.pos)
            when 2 then Knight.new(piece.color, piece.pos)
            when 3 then Bishop.new(piece.color, piece.pos)
            when 4 then Queen.new(piece.color, piece.pos)
            end
    self[piece.pos] = piece
  end

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

  # helper method for #castling_move: returns the rook positions for king side castling
  def king_castle(row)
    old_rook_col = 7
    new_rook_col = 5
    [[row, old_rook_col], [row, new_rook_col]]
  end

  # helper method for #castling_move: returns the rook positions for queen side castling
  def queen_castle(row)
    old_rook_col = 0
    new_rook_col = 3
    [[row, old_rook_col], [row, new_rook_col]]
  end

  # INSUFFICIENT MATERIAL HELPERS NEED REFACTORING
  # returns true if only kings remain
  def only_kings?
    pieces.all? { |piece| piece.instance_of?(King) }
  end

  # returns true if all pieces are kings and bishops, and if bishops are of the same square color
  def only_kings_bishops?
    same_color_bishops? && pieces.all? { |piece| piece.instance_of?(King) || piece.instance_of?(Bishop) }
  end

  def only_kings_knights?
    pieces.all? { |piece| piece.instance_of?(King) || piece.instance_of?(Knight) } &&
      pieces.one? { |piece| piece.instance_of?(Knight) }
  end

  def same_color_bishops?
    bishops = pieces.select { |piece| piece.instance_of?(Bishop) }
    bishops.all? { |bishop| bishop.pos.sum.even? } || bishops.all? { |bishop| bishop.pos.sum.odd? }
  end
end
