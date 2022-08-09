# frozen_string_literal: true

# Translates a move made by a piece into Algebraic Notation
class Notation
  LETTERS = ('a'..'h').to_a.freeze
  NUMBERS = ('1'..'8').to_a.reverse.freeze
  CLASSES = {
    king: 'K',
    queen: 'Q',
    rook: 'R',
    knight: 'N',
    bishop: 'B',
    pawn: ''
  }.freeze
  MOVE_TYPES = {
    moves: '',
    captures: 'x',
    king_castle: '0-0',
    queen_castle: '0-0-0',
    en_passant: 'x',
    promotion: '='
  }.freeze

  attr_reader :moves, :piece, :start_pos, :end_pos, :move_type, :color, :promotion, :promotion_type, :check

  def initialize
    @moves = []
    @check = nil
  end

  def add_stats(piece, move_type, end_pos, promotion, promotion_type = nil)
    @piece = piece
    @start_pos = piece.pos
    @end_pos = end_pos
    @move_type = move_type
    @color = piece.color
    @promotion = promotion
    @promotion_type = promotion_type
  end

  # stores the translated move into @moves
  def add_notation(grid)
    translated = translate(grid)
    color == :white ? moves << [translated] : moves.last << translated
  end

  # translates the move into algebraic notation
  def translate(grid)
    return castling_type if move_type == :castling

    to_pc + disambiguation(grid) + to_move + pos_to_alg + to_prom + to_prom_type + to_ep
  end

  def to_pc
    CLASSES[class_type]
  end

  # returns the row or col as letter or number if there are multiple pieces that can make the same move
  def disambiguation(grid)
    mirrors = find_mirrors(grid)
    count = mirrors.size
    mirror = mirrors.first

    mirror.nil? || mirror.empty? ? '' : find_axis(mirror.row, count)
  end

  # finds any pieces identical to the original which contain the same move
  def find_mirrors(grid)
    ally_pieces = grid.flatten.select { |other| other.color == color }
    ally_pieces.select do |ally|
      next unless ally.moves.values.flatten(1).include?(end_pos)

      ally.instance_of?(piece.class) && !ally.equal?(piece)
    end
  end

  # returns a row, col, or both if any of the axis are same
  def find_axis(mirror_row, count)
    row, col = start_pos
    return pos_to_alg(start_pos) if count > 1

    mirror_row == row ? LETTERS[col] : NUMBERS[row]
  end

  # returns the corresponding move type as algebraic notation type
  def to_move
    return pawn_move_type if piece.instance_of?(Pawn)

    MOVE_TYPES[move_type]
  end

  def pawn_move_type
    pawn_cap + MOVE_TYPES[move_type]
  end

  def pawn_cap
    move_type == :captures || move_type == :en_passant ? to_let(piece.col) : ''
  end

  def class_type
    piece.class.to_s.downcase.to_sym
  end

  # returns the type of castling
  def castling_type
    return unless [2, 6].include?(end_pos.last)

    end_pos.last == 6 ? MOVE_TYPES[:king_castle] : MOVE_TYPES[:queen_castle]
  end

  # converts position indicies to algebraic notation by letter and number
  def pos_to_alg
    row, col = end_pos
    to_let(col) + to_num(row)
  end

  # converts column to algebraic notation letter
  def to_let(col)
    LETTERS[col]
  end

  # converts row to algebraic notation number
  def to_num(row)
    NUMBERS[row]
  end

  def to_prom
    promotion ? '=' : ''
  end

  def to_prom_type
    promotion_type.nil? ? '' : %w[R N B Q][promotion_type - 1]
  end

  # returns the algebraic notation for en passant
  def to_ep
    return '' unless piece.instance_of?(Pawn)

    move_type == :en_passant ? ' e.p.' : ''
  end

  def add_check
    move = moves.last.last
    move.match?(/ .e.p/) ? move.insert(-6, '+') : move.concat('+')
  end

  def add_checkmate
    move = moves.last.last
    move.gsub!('+', '#')
  end

  def reset
    @promotion = nil
    @promotion = nil
  end
end
