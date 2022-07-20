# frozen_string_literal: true

require 'pieces/queen'
require 'pieces/piece'
require 'board'

describe Queen do
  let(:board) { instance_double(Board) }
  let(:bpc) { instance_double(Piece, color: :black, empty?: false) }
  let(:wpc) { instance_double(Piece, color: :white, empty?: false) }
  let(:emp) { instance_double(NullPiece, color: :none, empty?: true) }

  describe '#valid_moves' do
    context 'when the queen has no moves' do
      subject(:wqn) { described_class.new(:white, [7, 3]) }
      let(:grid) do
        [
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, wpc, wpc, wpc, nil, nil, nil],
          [nil, nil, wpc, wqn, wpc, nil, nil, nil]
        ]
      end

      it 'returns an empty array' do
        allow(board).to receive(:grid).and_return(grid)
        valid_moves = wqn.valid_moves(board)
        expect(valid_moves).to be_empty
      end
    end

    context 'when the queen has spaces available before encountering an ally piece (6 moves)' do
      subject(:wqn) { described_class.new(:white, [2, 4]) }
      let(:grid) do
        [
          [nil, nil, wpc, nil, nil, nil, nil, nil],
          [nil, nil, nil, emp, wpc, wpc, nil, nil],
          [nil, nil, nil, wpc, wqn, emp, emp, wpc],
          [nil, nil, nil, emp, wpc, wpc, nil, nil],
          [nil, nil, emp, nil, nil, nil, nil, nil],
          [nil, emp, nil, nil, nil, nil, nil, nil],
          [wpc, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil]
        ]
      end

      it 'should return 6 moves' do
        allow(board).to receive(:grid).and_return(grid)
        valid_moves = wqn.valid_moves(board)
        expect(valid_moves).to contain_exactly([1, 3], [2, 5], [2, 6], [3, 3], [4, 2], [5, 1])
      end
    end

    context 'when queen has 3 captures and 4 move available' do
      subject(:wqn) { described_class.new(:white, [2, 4]) }
      let(:grid) do
        [
          [nil, nil, bpc, nil, emp, nil, bpc, nil],
          [nil, nil, nil, emp, wpc, wpc, nil, nil],
          [nil, nil, nil, wpc, wqn, emp, wpc, nil],
          [nil, nil, nil, wpc, emp, bpc, nil, nil],
          [nil, nil, nil, nil, emp, nil, bpc, nil],
          [nil, nil, nil, nil, bpc, nil, nil, nil],
          [nil, nil, nil, nil, emp, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil]
        ]
      end

      it 'returns an array with 7 moves' do
        allow(board).to receive(:grid).and_return(grid)
        valid_moves = wqn.valid_moves(board)
        expect(valid_moves).to contain_exactly([0, 2], [1, 3], [2, 5], [3, 4], [4, 4], [5, 4], [3, 5])
      end
    end
  end
end
