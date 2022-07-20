# frozen_string_literal: true

require 'pieces/piece'
require 'pieces/knight'
require 'pieces/nullpiece'
require 'board'

describe Knight do
  let(:board) { instance_double(Board) }
  let(:bpc) { instance_double(Piece, color: :black, empty?: false) }
  let(:wpc) { instance_double(Piece, color: :white, empty?: false) }
  let(:emp) { instance_double(NullPiece, color: :none, empty?: true) }

  describe '#valid_moves' do
    context 'when the knight has no moves' do
      subject(:bkn) { described_class.new(:black, [0, 5]) }
      let(:grid) do
        [
          [nil, nil, nil, nil, nil, bkn, nil, nil],
          [nil, nil, nil, bpc, nil, nil, nil, bpc],
          [nil, nil, nil, nil, bpc, nil, bpc, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil]
        ]
      end

      it 'returns an empty array' do
        allow(board).to receive(:grid).and_return(grid)
        valid_moves = bkn.valid_moves(board)
        expect(valid_moves).to be_empty
      end
    end

    context 'when the knight is has 8 empty spaces available' do
      subject(:bkn) { described_class.new(:black, [2, 4]) }
      let(:grid) do
        [
          [nil, nil, nil, emp, nil, emp, nil, nil],
          [nil, nil, emp, nil, nil, nil, emp, nil],
          [nil, nil, nil, nil, bkn, nil, nil, nil],
          [nil, nil, emp, nil, nil, nil, emp, nil],
          [nil, nil, nil, emp, nil, emp, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil]
        ]
      end

      it 'should return all 8 moves' do
        allow(board).to receive(:grid).and_return(grid)
        valid_moves = bkn.valid_moves(board)
        expect(valid_moves).to contain_exactly([0, 3], [0, 5], [1, 2], [1, 6], [3, 2], [3, 6], [4, 3], [4, 5])
      end
    end

    context 'when knight has 3 captures and 1 move available' do
      subject(:bkn) { described_class.new(:black, [2, 4]) }
      let(:grid) do
        [
          [nil, nil, nil, emp, nil, bpc, nil, nil],
          [nil, nil, wpc, nil, nil, nil, bpc, nil],
          [nil, nil, nil, nil, bkn, nil, nil, nil],
          [nil, nil, wpc, nil, nil, nil, bpc, nil],
          [nil, nil, nil, wpc, nil, bpc, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil]
        ]
      end

      it 'returns 4 moves' do
        allow(board).to receive(:grid).and_return(grid)
        valid_moves = bkn.valid_moves(board)
        expect(valid_moves).to contain_exactly([0, 3], [1, 2], [3, 2], [4, 3])
      end
    end
  end
end
