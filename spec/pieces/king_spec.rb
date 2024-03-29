# frozen_string_literal: true

require 'pieces/king'
require 'board'

describe King do
  let(:board) { instance_double(Board, last_move: nil) }
  let(:bpc) { instance_double(Piece, color: :black, empty?: false) }
  let(:wpc) { instance_double(Piece, color: :white, empty?: false) }
  let(:emp) { instance_double(NullPiece, color: :none, empty?: true) }
  let(:last_move) { board.last_move }

  describe '#update_moves' do
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
        allow(bki).to receive(:moved).and_return(true)
        bki.update_moves(grid, last_move)
        update_moves = bki.moves[:moves]
        expect(update_moves).to be_empty
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
        allow(bki).to receive(:moved).and_return(true)
        bki.update_moves(grid, last_move)
        update_moves = bki.moves[:moves]
        expect(update_moves).to contain_exactly([0, 3], [0, 4], [0, 5], [1, 3], [1, 5], [2, 3], [2, 4], [2, 5])
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

      it 'returns 1 move' do
        allow(bki).to receive(:moved).and_return(true)
        bki.update_moves(grid, last_move)
        update_moves = bki.moves[:moves]
        expect(update_moves).to contain_exactly([0, 4])
      end

      it 'returns 3 captures' do
        allow(bki).to receive(:moved).and_return(true)
        bki.update_moves(grid, last_move)
        valid_captures = bki.moves[:captures]
        expect(valid_captures).to contain_exactly([0, 3], [1, 5], [2, 4])
      end
    end

    context 'when a castling move is presented' do
      let(:bki) { described_class.new(:black, [0, 4]) }
      let(:wki) { described_class.new(:black, [7, 4]) }
      let(:brk) { instance_double(Rook, color: :black, empty?: false, moved: false) }
      let(:wrk) { instance_double(Rook, color: :white, empty?: false, moved: false) }
      let(:grid) do
        [
          [emp, emp, emp, emp, bki, emp, emp, brk],
          [nil, nil, nil, emp, emp, emp, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, emp, emp, emp, nil, nil],
          [wrk, emp, emp, emp, wki, emp, emp, emp]
        ]
      end
      it 'should handle king side castling' do
        allow(bki).to receive(:castling).and_return(true)
        allow(bki).to receive(:moved).and_return(false)
        allow(brk).to receive(:instance_of?).with(Rook).and_return(true)
        bki.update_moves(grid, last_move)
        king_castling = bki.moves[:castling]
        expect(king_castling).to contain_exactly([0, 6])
      end

      it 'should handle queen side castling' do
        allow(wki).to receive(:castling).and_return(true)
        allow(wki).to receive(:moved).and_return(false)
        allow(wrk).to receive(:instance_of?).with(Rook).and_return(true)
        wki.update_moves(grid, last_move)
        queen_castling = wki.moves[:castling]
        expect(queen_castling).to contain_exactly([7, 2])
      end
    end

    context 'when a castling move is not presented' do
      let(:bki) { described_class.new(:black, [0, 4]) }
      let(:wki) { described_class.new(:black, [7, 4]) }
      let(:brk) { instance_double(Rook, color: :black, empty?: false, moved: false) }
      let(:wrk) { instance_double(Rook, color: :white, empty?: false, moved: false) }
      let(:grid) do
        [
          [emp, emp, emp, emp, bki, bpc, emp, brk],
          [nil, nil, nil, emp, emp, emp, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, emp, emp, emp, nil, nil],
          [wrk, emp, emp, emp, wki, emp, emp, emp]
        ]
      end
      it 'will not add a move if castling is disabled' do
        allow(bki).to receive(:castling).and_return(false)
        bki.update_moves(grid, last_move)
        king_castling = bki.moves[:castling]
        expect(king_castling).to be_empty
      end

      it 'will not add a move if there is a piece between rooks' do
        allow(bki).to receive(:moved).and_return(false)
        bki.update_moves(grid, last_move)
        king_castling = bki.moves[:castling]
        expect(king_castling).to be_empty
      end

      it 'will not add a move if the king has been moved' do
        allow(bki).to receive(:moved).and_return(true)
        bki.update_moves(grid, last_move)
        king_castling = bki.moves[:castling]
        expect(king_castling).to be_empty
      end

      it 'will not add a move if the rook has been moved' do
        allow(wrk).to receive(:moved).and_return(true)
        wki.update_moves(grid, last_move)
        queen_castling = wki.moves[:castling]
        expect(queen_castling).to be_empty
      end
    end
  end
end
