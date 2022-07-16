# frozen_string_literal: true

require 'board'

describe Board do
  subject(:board) { described_class.new }
  let(:grid) { board.instance_variable_get(:@grid) }
  let(:valid_pos_one) { [1, 2] }
  let(:valid_pos_two) { [5, 6] }
  let(:invalid_pos) { [-25, 16] }
  # let(:piece) { instance_double(Piece) }

  describe '#[]' do
    context 'when given an argument with an array with indicies representing a position on the board' do
      it 'should not raise an error' do
        expect { board[valid_pos_one] }.not_to raise_error
      end

      it 'should raise an error when the position not within the 8x8 grid' do
        expect { board[invalid_pos] }.to raise_error('Invalid position')
      end

      it 'should return the element at the position of the board' do
        grid[1][2] = 'hello'
        expect(board[valid_pos_one]).to eq('hello')
        expect(board[valid_pos_two]).to eq(nil) # change to null piece later
      end
    end
  end

  describe '#[]=' do
    let(:pawn) { :P }
    let(:rook) { :R }

    context 'when given an argument with an array with indicies representing a position on the board' do
      it 'should not raise an error' do
        expect { board[valid_pos_one] = pawn }.not_to raise_error
      end

      it 'should place the given piece on the given position on the board' do
        board[valid_pos_one] = pawn
        expect(board[valid_pos_one]).to eq(pawn)
        board[valid_pos_two] = rook
        expect(board[valid_pos_two]).to eq(rook)
      end

      it 'should raise an error when the position not within the 8x8 grid' do
        expect { board[invalid_pos] = pawn }.to raise_error('Invalid position')
      end
    end
  end

  describe '#valid_pos?' do
    context 'when the position is between 1 and 7' do
      it 'should return true' do
        expect(board).to be_valid_pos(valid_pos_one)
      end
    end

    context 'when the position is not between 1 and 7' do
      it 'should return false' do
        expect(board).to_not be_valid_pos(invalid_pos)
      end
    end
  end
end
