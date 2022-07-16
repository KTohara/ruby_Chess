# frozen_string_literal: true

require 'board'

describe Board do
  subject(:board) { described_class.new }
  # let(:piece) { instance_double(Piece) }

  describe '#[]' do
    context 'when given an argument with an array with indicies representing a position on the board' do
      let(:pos) { [1, 2] }
      let(:invalid_pos) { [25, 16] }

      it 'should not raise an error' do
        expect { board[pos] }.not_to raise_error
      end

      it 'should raise an error when the position not within the 8x8 grid' do
        expect { board[invalid_pos] }.to raise_error('Invalid position')
      end

      let(:grid) { board.instance_variable_get(:@grid) }
      let(:pos_1) { [1, 2] }
      let(:pos_2) { [0, 0] }

      it 'should return the element at the position of the board' do
        grid[1][2] = 'hello'
        expect(board[pos_1]).to eq('hello')
        expect(board[pos_2]).to eq(nil) # change to null piece later
      end
    end
  end

  describe '#[]=' do
    let(:grid) { board.instance_variable_get(:@grid) }
    let(:pos_1) { [1, 1] }
    let(:pos_2) { [6, 5] }
    let(:pawn) { :P }
    let(:rook) { :R }
    let(:invalid_pos) { [9, 16] }
    context 'when given an argument with an array with indicies representing a position on the board' do
      it 'should not raise an error' do
        expect { board[pos_1] = pawn }.not_to raise_error
      end
    
      it 'should place the given piece on the given position on the board' do
        board[pos_1] = pawn
        expect(board[pos_1]).to eq(pawn)
        board[pos_2] = rook
        expect(board[pos_2]).to eq(rook)
      end

      it 'should raise an error when the position not within the 8x8 grid' do
        allow(board).to receive(:valid_pos?)
        expect { board[invalid_pos] = pawn }.to raise_error('Invalid position')
      end
    end
  end

  describe '#valid_pos?' do
    context 'when the position is between 1 and 7' do
      let(:valid_pos) { [1, 7] }
      it 'should return true' do
        expect(board).to be_valid_pos(valid_pos)
      end
    end

    context 'when the position is not between 1 and 7' do
      let(:invalid_pos) { [-5, 17] }
      it 'should return false' do
        expect(board).to_not be_valid_pos(invalid_pos)
      end
    end
  end

  describe '#create_board' do
  end
end
