# frozen_string_literal: true

require 'pieces/pawn'
require 'pieces/piece'
require 'board'

describe Pawn do
  let(:board) { instance_double(Board, last_move: nil) }
  let(:bpc) { instance_double(Piece, 'Black', color: :black, empty?: false) }
  let(:wpc) { instance_double(Piece, 'White', color: :white, empty?: false) }
  let(:emp) { instance_double(NullPiece, 'Empty', color: :none, empty?: true) }
  let(:last_move) { board.last_move }

  describe '#update_moves' do
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

      it 'returns empty' do
        bpa.update_moves(grid, last_move)
        moves = bpa.moves
        expect(moves).to be_empty
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

      it 'returns a position regardless of color' do
        bpa.update_moves(grid, last_move)
        bl_moves = bpa.moves[:moves]
        expect(bl_moves).to contain_exactly([2, 7])

        wpa.update_moves(grid, last_move)
        wh_moves = wpa.moves[:moves]
        expect(wh_moves).to contain_exactly([5, 0])
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

      it 'returns one position' do
        bpa.single_jump(grid)
        moves = bpa.moves[:moves]
        expect(moves).to contain_exactly([2, 0])
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

      it 'returns an empty' do
        bpa.single_jump(grid)
        moves = bpa.moves[:moves]
        expect(moves).to be_empty
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
        bpa.double_jump(grid)
        moves = bpa.moves[:moves]
        expect(moves).to contain_exactly([3, 4])
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

      it 'returns empty' do
        bpa.instance_variable_set(:@moved, true)
        bpa.double_jump(grid)
        moves = bpa.moves[:moves]
        expect(moves).to be_empty
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
        wpa.captures(grid)
        captures = wpa.moves[:captures]
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
        wpa.captures(grid)
        wh_captures = wpa.moves[:captures]
        expect(wh_captures).to be_empty

        bpa.captures(grid)
        bl_captures = bpa.moves[:captures]
        expect(bl_captures).to be_empty
      end
    end
  end

  describe '#en_passant_capture' do
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
        allow(board).to receive(:last_move).and_return([3, 1])
        allow(bpa).to receive(:instance_of?).with(Pawn).and_return(true)
        allow(wpa).to receive(:en_passant).and_return(true)
        wpa.en_passant_capture(grid, last_move)
        en_passant = wpa.moves[:en_passant]
        expect(en_passant).to contain_exactly([2, 1])
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
        allow(bpa).to receive(:instance_of?).with(Pawn).and_return(true)
        allow(wpa).to receive(:en_passant).and_return(true)
        wpa.en_passant_capture(grid, last_move)
        en_passant = wpa.moves[:en_passant]
        expect(en_passant).to be_empty
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
        allow(bpa).to receive(:instance_of?).with(Pawn).and_return(true)
        allow(wpa).to receive(:en_passant).and_return(false)
        wpa.en_passant_capture(grid, last_move)
        en_passant = wpa.moves[:en_passant]
        expect(en_passant).to be_empty
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
        allow(bp1).to receive(:instance_of?).with(Pawn).and_return(true)
        allow(bp2).to receive(:instance_of?).with(Pawn).and_return(true)
        allow(wpa).to receive(:en_passant).and_return(true)
        wpa.en_passant_capture(grid, last_move)
        en_passant = wpa.moves[:en_passant]
        expect(en_passant).to contain_exactly([2, 1])
      end
    end
  end

  describe '#update_en_passant' do
    context 'when the black pawn has double jumped into an en passant position for the white pawn' do
      subject(:bpa) { described_class.new(:black, [3, 1]) }
      let(:wpa) { instance_double(Pawn, color: :white, en_passant: false) }
      let(:grid) do
        [
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, emp, nil, nil, nil, nil, nil, nil],
          [nil, emp, nil, nil, nil, nil, nil, nil],
          [emp, bpa, wpa, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil]
        ]
      end

      it 'updates @en_passant for white pawn' do
        bpa.instance_variable_set(:@moved, false)
        allow(wpa).to receive(:instance_of?).with(Pawn).and_return(true)
        expect(wpa).to receive(:en_passant=).and_return(true)
        bpa.update_en_passant(grid)
      end
    end

    context 'when the black pawn has not double jumped into an en passant position for the white pawn' do
      subject(:bpa) { described_class.new(:black, [3, 1]) }
      let(:wpa) { instance_double(Pawn, color: :white, en_passant: false) }
      let(:grid) do
        [
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, emp, nil, nil, nil, nil, nil, nil],
          [nil, emp, nil, nil, nil, nil, nil, nil],
          [emp, bpa, wpa, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil]
        ]
      end

      it 'does not update @en_passant for white pawn' do
        bpa.instance_variable_set(:@moved, true)
        allow(wpa).to receive(:instance_of?).with(Pawn).and_return(true)
        expect(wpa).not_to receive(:en_passant=)
        bpa.update_en_passant(grid)
      end
    end

    context 'when the black pawn has a non-pawn in a en passant position' do
      subject(:bpa) { described_class.new(:black, [3, 1]) }
      let(:wrk) { instance_double(Rook, color: :white) }
      let(:grid) do
        [
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, emp, nil, nil, nil, nil, nil, nil],
          [nil, emp, nil, nil, nil, nil, nil, nil],
          [emp, bpa, wrk, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil]
        ]
      end

      it 'does not update @en_passant for the non-pawn piece' do
        bpa.instance_variable_set(:@moved, false)
        expect(wrk).to receive(:instance_of?).with(Pawn).and_return(false)
        bpa.update_en_passant(grid)
      end
    end
  end

  describe '#en_passant_enemy_pos' do
    context 'when the pawn is black' do
      subject(:bpa) { described_class.new(:black, [4, 1]) }
      let(:en_passant_end_position) { [5, 2] }
      it 'returns the row before the end position, in relation to its forward direction' do
        expect(bpa.en_passant_enemy_pos(en_passant_end_position)).to eq([4, 2])
      end
    end

    context 'when the pawn is white' do
      subject(:bpa) { described_class.new(:white, [3, 2]) }
      let(:en_passant_end_position) { [2, 1] }
      it 'returns the row before the end position, in relation to its forward direction' do
        expect(bpa.en_passant_enemy_pos(en_passant_end_position)).to eq([3, 1])
      end
    end
  end

  describe '#promotable' do
    let(:wpa) { described_class.new(:white, [1, 5]) }
    let(:bpa) { described_class.new(:black, [6, 5]) }
    let(:no_promotion) { described_class.new(:white, [6, 5]) }

    it 'returns true if the white pawn is one move away from the first board row' do
      expect(wpa).to be_promotable
    end

    it 'returns true if the black pawn is one move away from the last board row' do
      expect(bpa).to be_promotable
    end

    it 'will not return if the pawn is in the opposite location' do
      expect(no_promotion).not_to be_promotable
    end
  end
end
