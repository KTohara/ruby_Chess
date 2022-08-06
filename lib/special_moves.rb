# frozen_string_literal: true

require_relative 'utility/messages'

# Handles board conditionals for specific piece special moves
module SpecialMoves
  include Messages
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

  # returns boolean if piece can castle, raises castling error if path to castling position causes a check
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

  # returns true if simulating a castling causes check
  def king_castling_causes_check?(turn_color)
    king = self[king_pos(turn_color)]
    return false if king.moves[:castling].empty?

    columns = [0, 7].select { |col| king.rook_path_clear?(grid, col) }
    columns.any? do |rook_col|
      castling_path(king, rook_col).any? { |move| move_causes_check?(turn_color, king.pos, move) }
    end
  end

  # returns an array of positions from piece to castling end position
  def castling_path(king, rook_col)
    return [] unless [7, 0].include?(rook_col) && grid[king.row][rook_col].instance_of?(Rook)

    prc = proc { |col| [king.row, col] }
    rook_col == 7 ? (king.col + 1...rook_col).map(&prc) : (rook_col + 2...king.col).map(&prc)
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

  # returns true if only kings remain
  def only_king?(turn_color)
    ally_pieces(turn_color).all? { |piece| piece.instance_of?(King) }
  end

  # returns true if remaining ally pieces are king and bishop
  # and if all bishops on board occupy same color square
  def only_king_bishop?(turn_color)
    same_color_bishops? &&
      ally_pieces(turn_color).all? do |piece|
        piece.instance_of?(King) || piece.instance_of?(Bishop)
      end
  end

  # returns true remaining ally pieces remaining are king and knight
  def only_king_knight?(turn_color)
    remaining = ally_pieces(turn_color)

    remaining.all? { |piece| piece.instance_of?(King) || piece.instance_of?(Knight) } &&
      remaining.one? { |piece| piece.instance_of?(Knight) }
  end

  # returns true if all bishops on board occupy the same colored square
  def same_color_bishops?
    bishops = pieces.select { |piece| piece.instance_of?(Bishop) }
    bishops.all? { |bishop| bishop.pos.sum.even? } || bishops.all? { |bishop| bishop.pos.sum.odd? }
  end
end
