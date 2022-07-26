# frozen_string_literal: true

require 'pieces/rook'
require 'pieces/piece'
require 'board'

describe Rook do
  let(:board) { instance_double(Board, last_move: nil) }
  let(:bpc) { instance_double(Piece, color: :black, empty?: false) }
  let(:wpc) { instance_double(Piece, color: :white, empty?: false) }
  let(:emp) { instance_double(NullPiece, color: :none, empty?: true) }
  let(:last_move) { board.last_move }

  describe '#valid_moves' do
    context 'when the rook has no moves' do
      subject(:wrk) { described_class.new(:white, [7, 3]) }
      let(:grid) do
        [
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, wpc, wpc, wpc, nil, nil, nil],
          [nil, nil, wpc, wrk, wpc, nil, nil, nil]
        ]
      end

      it 'returns an empty array' do
        wrk.valid_moves(grid, last_move)
        moves = wrk.moves[:moves]
        expect(moves).to be_empty
      end
    end

    context 'when the rook has spaces available before encountering an ally (3 moves)' do
      subject(:brk) { described_class.new(:black, [2, 7]) }
      let(:grid) do
        [
          [nil, nil, nil, nil, nil, nil, nil, emp],
          [nil, nil, nil, nil, nil, nil, nil, bpc],
          [emp, emp, emp, emp, wpc, bpc, emp, brk],
          [nil, nil, nil, nil, nil, nil, nil, emp],
          [nil, nil, nil, nil, nil, nil, nil, emp],
          [nil, nil, nil, nil, nil, nil, nil, bpc],
          [nil, nil, nil, nil, nil, nil, nil, emp],
          [nil, nil, nil, nil, nil, nil, nil, emp]
        ]
      end

      it 'returns 3 moves' do
        brk.valid_moves(grid, last_move)
        moves = brk.moves[:moves]
        expect(moves).to contain_exactly([2, 6], [3, 7], [4, 7])
      end
    end

    context 'when rook has 2 captures and 3 moves available' do
      subject(:brk) { described_class.new(:black, [2, 4]) }
      let(:grid) do
        [
          [nil, nil, nil, nil, emp, nil, nil, nil],
          [nil, nil, nil, nil, wpc, nil, nil, nil],
          [nil, nil, emp, bpc, brk, emp, wpc, nil],
          [nil, nil, nil, nil, emp, nil, nil, nil],
          [nil, nil, nil, nil, emp, nil, nil, nil],
          [nil, nil, nil, nil, bpc, nil, nil, nil],
          [nil, nil, nil, nil, wpc, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil]
        ]
      end

      it 'returns 3 moves' do
        brk.valid_moves(grid, last_move)
        moves = brk.moves[:moves]
        expect(moves).to contain_exactly([2, 5], [3, 4], [4, 4])
      end

      it 'returns 2 captures' do
        brk.valid_moves(grid, last_move)
        captures = brk.moves[:captures]
        expect(captures).to contain_exactly([1, 4], [2, 6])
      end
    end
  end
end
