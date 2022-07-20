# frozen_string_literal: true

require 'pieces/rook'
require 'pieces/piece'
require 'board'

describe Rook do
  let(:board) { instance_double(Board) }
  let(:bpc) { instance_double(Piece, color: :black, empty?: false) }
  let(:wpc) { instance_double(Piece, color: :white, empty?: false) }
  let(:emp) { instance_double(NullPiece, color: :none, empty?: true) }

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
        allow(board).to receive(:grid).and_return(grid)
        valid_moves = wrk.valid_moves(board)
        expect(valid_moves).to be_empty
      end
    end

    context 'when the rook has spaces available before encountering an ally (5 moves)' do
      subject(:brk) { described_class.new(:black, [2, 7]) }
      let(:grid) do
        [
          [nil, nil, nil, nil, nil, nil, nil, emp],
          [nil, nil, nil, nil, nil, nil, nil, bpc],
          [bpc, bpc, bpc, emp, wpc, wpc, emp, brk],
          [nil, nil, nil, nil, nil, nil, nil, emp],
          [nil, nil, nil, nil, nil, nil, nil, emp],
          [nil, nil, nil, nil, nil, nil, nil, wpc],
          [nil, nil, nil, nil, nil, nil, nil, emp],
          [nil, nil, nil, nil, nil, nil, nil, emp]
        ]
      end

      it 'should return 5 moves' do
        allow(board).to receive(:grid).and_return(grid)
        valid_moves = brk.valid_moves(board)
        expect(valid_moves).to contain_exactly([2, 5], [2, 6], [3, 7], [4, 7], [5, 7])
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

      it 'returns 5 moves' do
        allow(board).to receive(:grid).and_return(grid)
        valid_moves = brk.valid_moves(board)
        expect(valid_moves).to contain_exactly([1, 4], [2, 5], [2, 6], [3, 4], [4, 4])
      end
    end
  end
end
