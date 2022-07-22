# frozen_string_literal: true

require 'pieces/pawn'
require 'pieces/piece'
require 'board'

describe Pawn do
  let(:board) { instance_double(Board) }
  let(:bpc) { instance_double(Piece, 'Black', color: :black, empty?: false) }
  let(:wpc) { instance_double(Piece, 'White', color: :white, empty?: false) }
  let(:emp) { instance_double(NullPiece, 'Empty', color: :none, empty?: true) }

  describe '#valid_moves' do
    context 'when the pawn has no moves' do
      subject(:bpa) { described_class.new(:black, [1, 0]) }
      let(:grid) do
        [
          [bpc, bpc, nil, nil, nil, nil, nil, nil],
          [bpa, bpc, nil, nil, nil, nil, nil, nil],
          [bpc, bpc, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil]
        ]
      end

      it 'returns an empty array' do
        allow(board).to receive(:grid).and_return(grid)
        allow(board).to receive(:last_move)
        valid_moves = bpa.valid_moves(board)
        expect(valid_moves).to be_empty
      end
    end

    context 'when there is a move available' do
      let(:bpa) { described_class.new(:black, [1, 7]) }
      let(:wpa) { described_class.new(:white, [6, 0]) }
      let(:grid) do
        [
          [nil, nil, nil, nil, nil, nil, bpc, bpc],
          [nil, nil, nil, nil, nil, nil, bpc, bpa],
          [nil, nil, nil, nil, nil, nil, bpc, emp],
          [nil, nil, nil, nil, nil, nil, nil, bpc],
          [wpc, nil, nil, nil, nil, nil, nil, nil],
          [emp, wpc, nil, nil, nil, nil, nil, nil],
          [wpa, wpc, nil, nil, nil, nil, nil, nil],
          [wpc, wpc, nil, nil, nil, nil, nil, nil]
        ]
      end

      it 'will return a move regardless of color' do
        allow(board).to receive(:grid).and_return(grid)
        allow(board).to receive(:last_move)
        bpawn_valid_moves = bpa.valid_moves(board)
        expect(bpawn_valid_moves).to contain_exactly([2, 7])

        wpawn_valid_moves = wpa.valid_moves(board)
        expect(wpawn_valid_moves).to contain_exactly([5, 0])
      end
    end
  end

  describe '#single_jump' do
    context 'when the pawn make a single jump move' do
      subject(:bpa) { described_class.new(:black, [1, 0]) }
      let(:grid) do
        [
          [bpc, bpc, nil, nil, nil, nil, nil, nil],
          [bpa, bpc, nil, nil, nil, nil, nil, nil],
          [emp, bpc, nil, nil, nil, nil, nil, nil],
          [bpc, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil]
        ]
      end

      it 'returns one move' do
        allow(board).to receive(:grid).and_return(grid)
        single_jump = bpa.single_jump(board.grid)
        expect(single_jump).to eq([2, 0])
      end
    end

    context "when the pawn's path is blocked" do
      subject(:bpa) { described_class.new(:black, [1, 0]) }
      let(:grid) do
        [
          [bpc, bpc, nil, nil, nil, nil, nil, nil],
          [bpa, bpc, nil, nil, nil, nil, nil, nil],
          [bpc, bpc, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil]
        ]
      end

      it 'returns nil' do
        allow(board).to receive(:grid).and_return(grid)
        single_jump = bpa.single_jump(board.grid)
        expect(single_jump).to be_nil
      end
    end
  end

  describe '#double_jump' do
    context 'when the pawn has never moved and can double jump' do
      subject(:bpa) { described_class.new(:black, [1, 4]) }
      let(:grid) do
        [
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, bpa, nil, nil, nil],
          [nil, nil, nil, nil, emp, nil, nil, nil],
          [nil, nil, nil, nil, emp, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil]
        ]
      end

      it 'returns one move' do
        allow(board).to receive(:grid).and_return(grid)
        double_jump = bpa.double_jump(board.grid)
        expect(double_jump).to eq([3, 4])
      end
    end

    context 'when a pawn has moved and can no longer double jump' do
      subject(:bpa) { described_class.new(:black, [3, 4]) }
      let(:grid) do
        [
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, bpa, nil, nil, nil],
          [nil, nil, nil, nil, emp, nil, nil, nil],
          [nil, nil, nil, nil, emp, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil]
        ]
      end

      it 'returns nil' do
        allow(board).to receive(:grid).and_return(grid)
        allow(bpa).to receive(:moved).and_return(true)
        double_jump = bpa.double_jump(board.grid)
        expect(double_jump).to be_nil
      end
    end
  end

  describe '#captures' do
    context 'when the pawn can capture a piece' do
      subject(:wpa) { described_class.new(:white, [6, 2]) }
      let(:grid) do
        [
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, bpc, bpc, bpc, nil, nil, nil, nil],
          [nil, bpc, wpa, bpc, nil, nil, nil, nil],
          [nil, bpc, bpc, bpc, nil, nil, nil, nil]
        ]
      end

      it 'will only return direct diagonal moves' do
        allow(board).to receive(:grid).and_return(grid)
        captures = wpa.captures(board.grid)
        expect(captures).to contain_exactly([5, 1], [5, 3])
      end
    end

    context 'when the pawn has no captures' do
      let(:wpa) { described_class.new(:white, [6, 2]) }
      let(:bpa) { described_class.new(:black, [1, 7]) }
      let(:grid) do
        [
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, bpa],
          [nil, nil, nil, nil, nil, nil, bpc, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, emp, nil, wpc, nil, nil, nil, nil],
          [nil, nil, wpa, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil]
        ]
      end

      it 'returns an empty array' do
        allow(board).to receive(:grid).and_return(grid)
        wh_captures = wpa.captures(board.grid)
        expect(wh_captures).to be_empty

        bl_captures = bpa.captures(board.grid)
        expect(bl_captures).to be_empty
      end
    end
  end

  describe '#en_passant' do
    context 'when the pawn can perform en passant' do
      subject(:wpa) { described_class.new(:white, [3, 2]) }
      let(:bpa) { instance_double(Pawn, 'BP', color: :black) }
      let(:last_move) { [3, 1] }
      let(:grid) do
        [
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, emp, nil, nil, nil, nil, nil, nil],
          [nil, bpa, wpa, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil]
        ]
      end

      it 'returns one move' do
        allow(board).to receive(:grid).and_return(grid)
        allow(board).to receive(:last_move).and_return([3, 1])
        allow(bpa).to receive(:instance_of?).with(Pawn).and_return(true)
        allow(wpa).to receive(:en_passant).and_return(true)
        en_passant_capture = wpa.en_passant_capture(board.grid, last_move)
        expect(en_passant_capture).to contain_exactly([2, 1])
      end
    end

    context 'when the pawn is blocked from performing en passant' do
      subject(:wpa) { described_class.new(:white, [3, 2]) }
      let(:bpa) { instance_double(Pawn, 'BP', color: :black) }
      let(:last_move) { [3, 1] }
      let(:grid) do
        [
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, wpc, nil, wpc, nil, nil, nil, nil],
          [nil, bpa, wpa, bpa, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil]
        ]
      end

      it 'returns an empty array' do
        allow(board).to receive(:grid).and_return(grid)
        allow(bpa).to receive(:instance_of?).with(Pawn).and_return(true)
        allow(wpa).to receive(:en_passant).and_return(true)
        en_passant_capture = wpa.en_passant_capture(board.grid, last_move)
        expect(en_passant_capture).to be_empty
      end
    end

    context 'when the enemy pawn is in the correct location, but the first move was not a double jump' do
      subject(:wpa) { described_class.new(:white, [3, 2]) }
      let(:bpa) { instance_double(Pawn, 'BP', color: :black) }
      let(:last_move) { [3, 1] }
      let(:grid) do
        [
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, emp, nil, nil, nil, nil, nil, nil],
          [nil, bpa, wpa, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil]
        ]
      end

      it 'returns an empty array' do
        allow(board).to receive(:grid).and_return(grid)
        allow(bpa).to receive(:instance_of?).with(Pawn).and_return(true)
        allow(wpa).to receive(:en_passant).and_return(false)
        en_passant_capture = wpa.en_passant_capture(board.grid, last_move)
        expect(en_passant_capture).to be_empty
      end
    end

    context "when the pawn has two 'valid' en passant moves" do
      subject(:wpa) { described_class.new(:white, [3, 2]) }
      let(:bp1) { instance_double(Pawn, 'BP', color: :black) }
      let(:bp2) { instance_double(Pawn, 'BP', color: :black) }
      let(:last_move) { [3, 1] }
      let(:grid) do
        [
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, emp, nil, emp, nil, nil, nil, nil],
          [nil, bp1, wpa, bp2, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil]
        ]
      end

      it 'returns only one en passant move' do
        allow(board).to receive(:grid).and_return(grid)
        allow(bp1).to receive(:instance_of?).with(Pawn).and_return(true)
        allow(bp2).to receive(:instance_of?).with(Pawn).and_return(true)
        allow(wpa).to receive(:en_passant).and_return(true)
        en_passant_capture = wpa.en_passant_capture(board.grid, last_move)
        expect(en_passant_capture).to contain_exactly([2, 1])
      end
    end
  end
end
