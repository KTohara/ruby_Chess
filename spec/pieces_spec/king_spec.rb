# frozen_string_literal: true

require 'pieces/piece'
require 'pieces/king'
require 'pieces/nullpiece'
require 'board'

describe King do
  let(:board) { instance_double(Board) }
  let(:bpc) { instance_double(Piece, color: :black, empty?: false) }
  let(:wpc) { instance_double(Piece, color: :white, empty?: false) }
  let(:emp) { instance_double(NullPiece, color: :none, empty?: true) }

  describe '#valid_moves' do
    context 'when the king has no moves' do
      subject(:bki) { described_class.new(:black, [0, 4]) }
      let(:grid) do
        [
          [nil, nil, nil, bpc, bki, bpc, nil, nil],
          [nil, nil, nil, bpc, bpc, bpc, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil]
        ]
      end

      it 'returns an empty array' do
        allow(board).to receive(:grid).and_return(grid)
        valid_moves = bki.valid_moves(board)
        expect(valid_moves).to be_empty
      end
    end

    context 'when the king is has 8 empty spaces surrounding it' do
      subject(:bki) { described_class.new(:black, [1, 4]) }
      let(:grid) do
        [
          [nil, nil, nil, emp, emp, emp, nil, nil],
          [nil, nil, nil, emp, bki, emp, nil, nil],
          [nil, nil, nil, emp, emp, emp, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil]
        ]
      end

      it 'should return all 8 moves' do
        allow(board).to receive(:grid).and_return(grid)
        valid_moves = bki.valid_moves(board)
        expect(valid_moves).to contain_exactly([0, 3], [0, 4], [0, 5], [1, 3], [1, 5], [2, 3], [2, 4], [2, 5])
      end
    end

    context 'when king has 3 captures and 1 move available' do
      subject(:bki) { described_class.new(:black, [1, 4]) }
      let(:grid) do
        [
          [nil, nil, nil, wpc, emp, bpc, nil, nil],
          [nil, nil, nil, bpc, bki, wpc, nil, nil],
          [nil, nil, nil, bpc, wpc, bpc, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil]
        ]
      end

      it 'returns 4 moves' do
        allow(board).to receive(:grid).and_return(grid)
        valid_moves = bki.valid_moves(board)
        expect(valid_moves).to contain_exactly([0, 3], [0, 4], [1, 5], [2, 4])
      end
    end

    it 'should handle king side castling'
    it 'should handle queen side castling'
    it 'cannot castle if there is a piece between rooks'
    it 'cannot castle if the king or rook has been moved'
    it 'cannot castle if it is in check'
    it 'cannot go in a move that would enable a check or checkmate'
  end
end
