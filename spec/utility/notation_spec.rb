# frozen_string_literal: true

require 'utility/notation'
require 'pieces'

describe Notation do
  subject(:notation) { described_class.new }

  describe '#add_notation' do
    let(:grid) { double }
    let(:translated) { 'xf8=Q+' }
    context 'when the turn color is white' do
      it 'adds a translated notation into @moves' do
        allow(notation).to receive(:translate).and_return(translated)
        allow(notation).to receive(:color).and_return(:white)
        notation.add_notation(grid)
        expect(notation.moves).to include([translated])
      end
    end

    context 'when the turn color is black' do
      let(:other_translation) { 'xc5' }
      it 'adds a translated notation into the last array of @moves ' do
        notation.instance_variable_set(:@moves, [[translated]])
        allow(notation).to receive(:translate).and_return(other_translation)
        allow(notation).to receive(:color).and_return(:black)
        notation.add_notation(grid)
        expect(notation.moves).to eq([[translated, other_translation]])
      end
    end
  end

  describe '#to_pc' do
    it 'returns a uppercase representation of the class' do
      allow(notation).to receive(:class_type).and_return(:king)
      expect(notation.to_pc).to eq('K')
      allow(notation).to receive(:class_type).and_return(:queen)
      expect(notation.to_pc).to eq('Q')
      allow(notation).to receive(:class_type).and_return(:rook)
      expect(notation.to_pc).to eq('R')
      allow(notation).to receive(:class_type).and_return(:knight)
      expect(notation.to_pc).to eq('N')
      allow(notation).to receive(:class_type).and_return(:bishop)
      expect(notation.to_pc).to eq('B')
      allow(notation).to receive(:class_type).and_return(:pawn)
      expect(notation.to_pc).to eq('')
    end
  end

  describe '#disambiguation' do
    context 'if there is a piece with the same move as the end position' do
      let(:kn1) do
        instance_double(Knight, 'kn1',
                        pos: [0, 3],
                        color: :white,
                        empty?: false,
                        moves: { moves: [end_pos] })
      end
      let(:kn2) do
        instance_double(Knight, 'kn2',
                        row: 0,
                        color: :white,
                        empty?: false,
                        moves: { moves: [end_pos] })
      end
      let(:emp) { instance_double(NullPiece, color: :none) }
      let(:end_pos) { [3, 4] }
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
        allow(notation).to receive(:color).and_return(:white)
        allow(notation).to receive(:end_pos).and_return(end_pos)
        allow(notation).to receive(:piece).and_return(kn1)
        allow(notation).to receive(:start_pos).and_return(kn1.pos)
        expect(notation.disambiguation(grid)).to eq('d')
      end
    end
  end

  describe '#find_mirrors' do
    context 'when there is a mirror piece on the board with the same move as the original piece' do
      let(:kni) { instance_double(Knight, 'orig', color: :white, moves: { moves: [end_pos] }) }
      let(:kn1) { instance_double(Knight, 'kn1', color: :white, moves: { moves: [end_pos] }) }
      let(:kn2) { instance_double(Knight, 'kn2', color: :white, moves: { moves: [end_pos] }) }
      let(:kn3) { instance_double(Knight, 'kn3', color: :white, moves: { moves: [end_pos] }) }
      let(:kn4) { instance_double(Knight, 'kn4', color: :white, moves: { moves: [end_pos] }) }
      let(:emp) { instance_double(NullPiece, color: :none) }
      let(:end_pos) { [3, 4] }
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
      before do
        allow(notation).to receive(:color).and_return(:white)
        allow(notation).to receive(:piece).and_return(kni)
        allow(notation).to receive(:end_pos).and_return(end_pos)
      end
      it 'returns all pieces that are of the same class, color' do
        expect(notation.find_mirrors(grid)).to contain_exactly(kn1, kn2, kn3, kn4)
      end

      it 'does not return the original piece' do
        expect(notation.find_mirrors(grid)).not_to include(kni)
      end
    end
  end

  describe '#find_axis' do
    let(:mirr_row) { 1 }
    let(:start_pos) { [1, 5] }
    let(:count) { 1 }
    let(:find_axis) { notation.find_axis(mirr_row, count) }

    before do
      allow(notation).to receive(:start_pos).and_return(start_pos)
    end

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

  describe '#to_move' do
    context 'when given a symbol as a move type' do
      let(:pawn) { instance_double(Pawn) }
      let(:knight) { instance_double(Knight) }

      it 'returns "x" when the move a capture' do
        allow(notation).to receive(:piece).and_return(knight)
        allow(pawn).to receive(:instance_of?).with(Pawn).and_return(false)
        allow(notation).to receive(:move_type).and_return(:captures)
        expect(notation.to_move).to eq('x')
      end

      it 'returns "x" when the move is an en passant' do
        allow(notation).to receive(:piece).and_return(knight)
        allow(pawn).to receive(:instance_of?).with(Pawn).and_return(false)
        allow(notation).to receive(:move_type).and_return(:en_passant)
        expect(notation.to_move).to eq('x')
      end

      it 'returns an empty string when the move is just a move' do
        allow(notation).to receive(:piece).and_return(knight)
        allow(pawn).to receive(:instance_of?).with(Pawn).and_return(false)
        allow(notation).to receive(:move_type).and_return(:moves)
        expect(notation.to_move).to eq('')
      end

      context 'when the piece is a pawn' do
        it 'returns the annotated row and move type when move is a capture' do
          allow(notation).to receive(:piece).and_return(pawn)
          allow(notation).to receive(:start_pos).and_return([4, 5])
          allow(pawn).to receive(:instance_of?).with(Pawn).and_return(true)
          allow(notation).to receive(:move_type).and_return(:captures)
          expect(notation.to_move).to eq('ex')
        end

        it 'returns the an empty string when move is just a move' do
          allow(notation).to receive(:piece).and_return(pawn)
          allow(notation).to receive(:start_pos).and_return([4, 5])
          allow(pawn).to receive(:instance_of?).with(Pawn).and_return(true)
          allow(notation).to receive(:move_type).and_return(:moves)
          expect(notation.to_move).to eq('')
        end

        it 'returns the annotated row and move type when move is a en passant' do
          allow(notation).to receive(:piece).and_return(pawn)
          allow(notation).to receive(:start_pos).and_return([4, 5])
          allow(pawn).to receive(:instance_of?).with(Pawn).and_return(true)
          allow(notation).to receive(:move_type).and_return(:en_passant)
          expect(notation.to_move).to eq('ex')
        end
      end
    end
  end

  describe '#castling_type' do
    it 'returns 0-0 if the position col is 6' do
      allow(notation).to receive(:end_pos).and_return([1, 6])
      expect(notation.castling_type).to eq('0-0')
    end

    it 'returns 0-0-0 if the position col is not 6' do
      allow(notation).to receive(:end_pos).and_return([1, 2])
      expect(notation.castling_type).to eq('0-0-0')
    end

    it 'returns nil if the position col is neither 2 or 6' do
      allow(notation).to receive(:end_pos).and_return([1, 5])
      expect(notation.castling_type).to be_nil
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

  describe 'to_prom' do
    it 'returns "=" when promotion is true' do
      allow(notation).to receive(:promotion).and_return(true)
      expect(notation.to_prom).to eq('=')
    end

    it 'returns an empty space when promotion is false' do
      allow(notation).to receive(:promotion).and_return(false)
      expect(notation.to_prom).to eq('')
    end
  end

  describe 'to_prom_type' do
    it 'returns the corresponding class type when promotion type is a number between 1 and 4' do
      allow(notation).to receive(:promotion_type).and_return(1)
      expect(notation.to_prom_type).to eq('R')
      allow(notation).to receive(:promotion_type).and_return(2)
      expect(notation.to_prom_type).to eq('N')
      allow(notation).to receive(:promotion_type).and_return(3)
      expect(notation.to_prom_type).to eq('B')
      allow(notation).to receive(:promotion_type).and_return(4)
      expect(notation.to_prom_type).to eq('Q')
    end

    it 'returns an empty space when promotion type is nil' do
      allow(notation).to receive(:promotion).and_return(nil)
      expect(notation.to_prom).to eq('')
    end
  end

  describe '#to_ep' do
    let(:pawn) { instance_double(Pawn) }
    let(:knight) { instance_double(Knight) }

    it "returns a string ' e.p.' when piece is a pawn, and includes the same en passant move" do
      allow(notation).to receive(:piece).and_return(pawn)
      allow(notation).to receive(:move_type).and_return(:en_passant)
      allow(pawn).to receive(:instance_of?).with(Pawn).and_return(true)
      expect(notation.to_ep).to eq(' e.p.')
    end

    it 'returns an empty string when piece is a pawn, but does not include the same en passant move' do
      allow(notation).to receive(:piece).and_return(pawn)
      allow(notation).to receive(:move_type).and_return(:castling)
      allow(pawn).to receive(:instance_of?).with(Pawn).and_return(true)
      expect(notation.to_ep).to eq('')
    end

    it 'returns an empty string if the piece is not a pawn' do
      allow(notation).to receive(:piece).and_return(knight)
      allow(notation).to receive(:move_type).and_return(:castling)
      allow(pawn).to receive(:instance_of?).with(Pawn).and_return(false)
      expect(notation.to_ep).to eq('')
    end
  end

  describe 'add_check' do
    let(:before) { [['Bxg4']] }
    let(:after) { [['Bxg4+']] }
    it 'adds "+" to the very last notation made' do
      allow(notation).to receive(:moves).and_return(before)
      notation.add_check
      expect(notation.moves).to eq(after)
    end
  end

  describe 'add_checkmate' do
    let(:before) { [['Bxg4+']] }
    let(:after) { [['Bxg4#']] }
    it 'adds "+" to the very last notation made' do
      allow(notation).to receive(:moves).and_return(before)
      notation.add_checkmate
      expect(notation.moves).to eq(after)
    end
  end
end
