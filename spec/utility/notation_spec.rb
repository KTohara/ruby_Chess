# frozen_string_literal: true

require 'utility/notation'
require 'pieces'

describe Notation do
  subject(:notation) { described_class.new }

  describe '#castling_type' do
    it 'returns 0-0 if the position col is 6' do
      expect(notation.castling_type([1, 6])).to eq('0-0')
    end

    it 'returns 0-0-0 if the position col is not 6' do
      expect(notation.castling_type([1, 2])).to eq('0-0-0')
    end

    it 'returns nil if the position col is neither 2 or 6' do
      expect(notation.castling_type([1, 5])).to be_nil
    end
  end

  describe '#castling?' do
    let(:castling_piece) { instance_double(Piece, moves: { castling: [[0, 2]] }) }
    let(:non_castling_piece) { instance_double(Piece, moves: { captures: [[0, 2]] }) }

    it 'returns true if a piece includes a castling move' do
      expect(notation.castling?(castling_piece)).to be true
    end

    it 'returns false if a piece includes a castling move' do
      expect(notation.castling?(non_castling_piece)).to be false
    end
  end

  describe '#to_pc' do
    it 'returns the class type with the corresponding string symbol' do
      expect(notation.to_pc(King)).to eq('♚')
      expect(notation.to_pc(Queen)).to eq('♛')
      expect(notation.to_pc(Rook)).to eq('♜')
      expect(notation.to_pc(Knight)).to eq('♞')
      expect(notation.to_pc(Bishop)).to eq('♝')
      expect(notation.to_pc(Pawn)).to eq('')
    end
  end

  describe '#disambiguation' do
    context 'if there is a piece with the same move as the end position' do
      let(:kn1) do
        instance_double(Knight, 'kn1',
                        pos: [0, 3],
                        color: :white,
                        empty?: false,
                        moves: { moves: [3, 4] })
      end
      let(:kn2) do
        instance_double(Knight, 'kn2',
                        row: 0,
                        color: :white,
                        empty?: false,
                        moves: { moves: [3, 4] })
      end
      let(:emp) { instance_double(NullPiece, color: :none) }
      let(:emp_pos) { [3, 4] }
      let(:grid) do
        [
          [emp, emp, emp, kn1, emp, kn2, emp, emp],
          [emp, emp, emp, emp, emp, emp, emp, emp],
          [emp, emp, emp, emp, emp, emp, emp, emp],
          [emp, emp, emp, emp, emp, emp, emp, emp],
          [emp, emp, emp, emp, emp, emp, emp, emp],
          [emp, emp, emp, emp, emp, emp, emp, emp],
          [emp, emp, emp, emp, emp, emp, emp, emp],
          [emp, emp, emp, emp, emp, emp, emp, emp]
        ]
      end

      it 'returns the mirrored row/col as a letter or num' do
        allow(kn2).to receive(:row).and_return(0)
        expect(notation.disambiguation(grid, kn1, emp_pos)).to eq('d')
      end
    end
  end

  describe '#find_mirrors' do
    context 'when there is a mirror piece on the board with the same move as the original piece' do
      let(:kni) { instance_double(Knight, 'orig', color: :white, moves: { moves: [3, 4] }) }
      let(:kn1) { instance_double(Knight, 'kn1', color: :white, moves: { moves: [3, 4] }) }
      let(:kn2) { instance_double(Knight, 'kn2', color: :white, moves: { moves: [3, 4] }) }
      let(:kn3) { instance_double(Knight, 'kn3', color: :white, moves: { moves: [3, 4] }) }
      let(:kn4) { instance_double(Knight, 'kn4', color: :white, moves: { moves: [3, 4] }) }
      let(:emp) { instance_double(NullPiece, color: :none) }
      let(:emp_pos) { [3, 4] }
      let(:grid) do
        [
          [emp, emp, emp, kni, emp, kn1, emp, emp],
          [emp, emp, emp, emp, emp, emp, emp, emp],
          [emp, emp, emp, emp, emp, emp, emp, emp],
          [emp, emp, kn4, emp, emp, emp, kn2, emp],
          [emp, emp, emp, emp, emp, kn3, emp, emp],
          [emp, emp, emp, emp, emp, emp, emp, emp],
          [emp, emp, emp, emp, emp, emp, emp, emp],
          [emp, emp, emp, emp, emp, emp, emp, emp]
        ]
      end
      it 'returns all pieces that are of the same class, color' do
        expect(notation.find_mirrors(grid, kni, emp_pos)).to contain_exactly(kn1, kn2, kn3, kn4)
      end

      it 'does not return the original piece' do
        expect(notation.find_mirrors(grid, kni, emp_pos)).not_to include(kni)
      end
    end
  end

  describe '#find_axis' do
    let(:mirr_row) { 1 }
    let(:orig_move) { [1, 5] }
    let(:count) { 1 }
    let(:find_axis) { notation.find_axis(mirr_row, orig_move, count) }

    context 'when mirrored piece count is 1, and rows are same' do
      it 'returns the letter associated with the col index' do
        expect(find_axis).to eq('f')
      end
    end

    context 'when mirrored piece count is 1, and cols are same' do
      let(:mirr_row) { 5 }
      it 'returns the number associated with the num index' do
        expect(find_axis).to eq('7')
      end
    end

    context 'when mirrored piece count is 2, and mirrored row and original row are the same' do
      let(:count) { 2 }
      it 'returns the both the letter and number associated with the row and col' do
        expect(find_axis).to eq('f7')
      end
    end
  end

  describe '#move_type' do
    let(:ep_pawn) { instance_double(Pawn, col: 4, moves: { captures: [], en_passant: [[2, 5]] }) }
    let(:cap_pawn) { instance_double(Pawn, col: 4, moves: { captures: [[2, 5]], en_passant: [] }) }
    let(:promo_pawn) { instance_double(Pawn, moves: { captures: [], en_passant: [], promotion: [[2, 5]] }) }
    let(:cap_knight) { instance_double(Knight, moves: { captures: [[2, 5]], en_passant: [] }) }
    let(:check_queen) { instance_double(Queen, moves: { captures: [], en_passant: [], check: [[2, 5]] }) }
    let(:mate_rook) { instance_double(Rook, moves: { captures: [], en_passant: [], checkmate: [[2, 5]] }) }
    let(:normie_pawn) { instance_double(Pawn, moves: { captures: [], en_passant: [], moves: [[2, 5]] }) }
    let(:move) { [2, 5] }

    context 'when piece is a pawn and has a capture or en passant move' do
      it 'returns the column as a letter when it has a capture' do
        allow(cap_pawn).to receive(:instance_of?).with(Pawn).and_return(true)
        expect(notation.move_type(cap_pawn, move)).to include('e')
      end

      it 'returns the column as a letter when it has a en passant' do
        allow(ep_pawn).to receive(:instance_of?).with(Pawn).and_return(true)
        expect(notation.move_type(ep_pawn, move)).to include('e')
      end
    end

    context 'when piece has a special move type' do
      it "returns '=' when the move is a promotion" do
        allow(ep_pawn).to receive(:instance_of?).with(Pawn).and_return(false)
        expect(notation.move_type(promo_pawn, move)).to eq('=')
      end

      it "returns 'x' when the move is a capture" do
        allow(ep_pawn).to receive(:instance_of?).with(Pawn).and_return(false)
        expect(notation.move_type(cap_knight, move)).to eq('x')
      end

      it "returns '+' when the move is a check" do
        allow(ep_pawn).to receive(:instance_of?).with(Pawn).and_return(false)
        expect(notation.move_type(check_queen, move)).to eq('+')
      end

      it "returns '#' when the move is a checkmate" do
        allow(ep_pawn).to receive(:instance_of?).with(Pawn).and_return(false)
        expect(notation.move_type(mate_rook, move)).to eq('#')
      end
    end

    context 'when piece does not have a special move type (only moved)' do
      it 'returns an empty string' do
        allow(normie_pawn).to receive(:instance_of?).with(Pawn).and_return(true)
        expect(notation.move_type(normie_pawn, move)).to eq('')
      end
    end
  end

  describe '#pos_to_alg' do
    it 'translates the position to the correct algebraic notation position' do
      expect(notation.pos_to_alg([0, 0])).to eq('a8')
      expect(notation.pos_to_alg([4, 4])).to eq('e4')
      expect(notation.pos_to_alg([7, 7])).to eq('h1')
      expect(notation.pos_to_alg([3, 1])).to eq('b5')
      expect(notation.pos_to_alg([6, 7])).to eq('h2')
      expect(notation.pos_to_alg([2, 5])).to eq('f6')
    end
  end

  describe '#to_let' do
    it 'returns the index associated with @letters' do
      expect(notation.to_let(0)).to eq('a')
      expect(notation.to_let(3)).to eq('d')
      expect(notation.to_let(5)).to eq('f')
      expect(notation.to_let(7)).to eq('h')
    end
  end

  describe '#to_num' do
    it 'returns the index associated with @numbers' do
      expect(notation.to_num(0)).to eq('8')
      expect(notation.to_num(3)).to eq('5')
      expect(notation.to_num(5)).to eq('3')
      expect(notation.to_num(7)).to eq('1')
    end
  end

  describe '#ep' do
    let(:pawn) { instance_double(Pawn, moves: { en_passant: [[2, 5]] }) }
    let(:non_ep_pawn) { instance_double(Pawn, moves: { en_passant: [[2, 7]] }) }
    let(:knight) { instance_double(Knight) }
    let(:move) { [2, 5] }

    it "returns a string ' e.p.' when piece is a pawn, and includes the same en passant move" do
      allow(pawn).to receive(:instance_of?).with(Pawn).and_return(true)
      expect(notation.ep(pawn, move)).to eq(' e.p.')
    end

    it 'returns an empty string when piece is a pawn, but does not include the same en passant move' do
      allow(pawn).to receive(:instance_of?).with(Pawn).and_return(true)
      expect(notation.ep(non_ep_pawn, move)).to eq('')
    end

    it 'returns an empty string if the piece is not a pawn' do
      expect(notation.ep(knight, move)).to eq('')
    end
  end
end
