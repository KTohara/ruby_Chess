# frozen_string_literal: true

require 'pieces/bishop'
require 'pieces/piece'
require 'board'

describe Bishop do
  let(:board) { instance_double(Board, last_move: nil) }
  let(:bpc) { instance_double(Piece, color: :black, empty?: false) }
  let(:wpc) { instance_double(Piece, color: :white, empty?: false) }
  let(:emp) { instance_double(NullPiece, color: :none, empty?: true) }
  let(:last_move) { board.last_move }

  describe '#valid_moves' do
    context 'when the rook has no moves' do
      subject(:wbi) { described_class.new(:white, [7, 3]) }
      let(:grid) do
        [
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, wpc, wpc, wpc, nil, nil, nil],
          [nil, nil, wpc, wbi, wpc, nil, nil, nil]
        ]
      end

      it 'returns an empty array' do
        wbi.valid_moves(grid, last_move)
        valid_moves = wbi.moves[:moves]
        expect(valid_moves).to be_empty
      end
    end

    context 'when the rook has spaces available before encountering an ally (5 moves)' do
      subject(:bbi) { described_class.new(:black, [2, 7]) }
      let(:grid) do
        [
          [nil, nil, nil, nil, nil, bpc, nil, nil],
          [nil, nil, nil, nil, nil, nil, emp, nil],
          [nil, nil, nil, nil, nil, nil, nil, bbi],
          [nil, nil, nil, nil, nil, nil, emp, nil],
          [nil, nil, nil, nil, nil, emp, nil, nil],
          [nil, nil, nil, nil, emp, nil, nil, nil],
          [nil, nil, nil, emp, nil, nil, nil, nil],
          [nil, nil, bpc, nil, nil, nil, nil, nil]
        ]
      end

      it 'should return 5 moves' do
        bbi.valid_moves(grid, last_move)
        valid_moves = bbi.moves[:moves]
        expect(valid_moves).to contain_exactly([1, 6], [3, 6], [4, 5], [5, 4], [6, 3])
      end
    end

    context 'when rook has 2 captures and 3 moves available' do
      subject(:bbi) { described_class.new(:black, [2, 4]) }
      let(:grid) do
        [
          [nil, nil, wpc, nil, nil, nil, wpc, nil],
          [nil, nil, nil, emp, nil, bpc, nil, nil],
          [nil, nil, nil, nil, bbi, nil, nil, nil],
          [nil, nil, nil, emp, nil, bpc, nil, nil],
          [nil, nil, emp, nil, nil, nil, emp, nil],
          [nil, wpc, nil, nil, nil, nil, nil, nil],
          [emp, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil]
        ]
      end

      it 'returns 3 moves' do
        bbi.valid_moves(grid, last_move)
        valid_moves = bbi.moves[:moves]
        expect(valid_moves).to contain_exactly([1, 3], [3, 3], [4, 2])
      end

      it 'returns 2 captures' do
        bbi.valid_moves(grid, last_move)
        valid_captures = bbi.moves[:captures]
        expect(valid_captures).to contain_exactly([0, 2], [5, 1])
      end
    end
  end
end
