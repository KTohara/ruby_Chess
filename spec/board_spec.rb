# frozen_string_literal: true

require 'board'

describe Board do
  subject(:board) { described_class.new }
  let(:grid) { board.instance_variable_get(:@grid) }

  describe '#initialize' do
    context 'when initialized' do
      let(:black_back_row) { 0 }
      let(:black_pawn_row) { 1 }
      let(:white_pawn_row) { 6 }
      let(:white_back_row) { 7 }

      it 'sets @grid to an 8 by 8 array' do
        expect(grid).to be_a_kind_of(Array)
        expect(grid.length).to eq(8)
        expect(grid[0].length).to eq(8)
      end

      it 'sets all the black pieces on the board' do
        expect(grid[black_pawn_row].all? { |piece| piece.color == :black }).to be true
        expect(grid[black_back_row].all? { |piece| piece.color == :black }).to be true
      end

      it 'sets all the white pieces on the board' do
        expect(grid[white_pawn_row].all? { |piece| piece.color == :white }).to be true
        expect(grid[white_back_row].all? { |piece| piece.color == :white }).to be true
      end

      it "should set the correct back pieces on each color's side" do
        back_row = [Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook]

        back_row.each_with_index do |piece_class, i|
          expect(grid[black_back_row][i]).to be_a_kind_of(piece_class)
          expect(grid[white_back_row][i]).to be_a_kind_of(piece_class)
        end
      end

      it "should set pawns on each color's side" do
        expect(grid[black_pawn_row]).to all(be_a(Pawn))
        expect(grid[white_pawn_row]).to all(be_a(Pawn))
      end

      it 'should all be instances of NullPiece in rows 2 through 5' do
        (2..5).each do |row|
          expect(grid[row]).to all(be_a_kind_of(NullPiece))
        end
      end
    end
  end

  describe '#[]' do
    let(:valid_pos_one) { [1, 2] }
    let(:valid_pos_two) { [5, 6] }
    let(:invalid_pos) { [-25, 16] }

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
        expect(board[valid_pos_two]).to be_empty
      end
    end
  end

  describe '#[]=' do
    let(:valid_pos_one) { [1, 2] }
    let(:valid_pos_two) { [5, 6] }
    let(:invalid_pos) { [-25, 16] }
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
    let(:valid_pos_one) { [1, 2] }
    let(:invalid_pos) { [-25, 16] }

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

  describe '#empty?' do
    it 'should take in a array of indices as an argument' do
      expect { board.empty?([3, 0]) }.not_to raise_error
    end

    context 'when the position given is empty' do
      it 'should return true' do
        expect(board).to be_empty([3, 0])
      end
    end

    context 'when the position given is not empty' do
      it 'should return false' do
        grid[3][0] = 'hello'
        expect(board).not_to be_empty([3, 0])
      end
    end
  end

  describe '#validate_start_pos' do
    let(:turn_color) { :white }
    let(:black_pawn_a7) { [1, 0] }
    let(:white_pawn_a2) { [6, 0] }
    let(:pos_d4) { [4, 3] }

    it 'should raise an error if the start position is empty' do
      expect { board.validate_start_pos(turn_color, pos_d4) }.to raise_error('Square is empty')
    end

    it "should raise an error if the start position is the opponent's piece" do
      expect { board.validate_start_pos(turn_color, black_pawn_a7) }.to raise_error('You must move your own pieces')
    end

    it 'returns nil if no errors are raised' do
      expect(board.validate_start_pos(turn_color, white_pawn_a2)).to be_nil
    end
  end

  describe '#validate_end_pos' do
    let(:turn_color) { :white }
    let(:black_pawn_a7) { [1, 0] }
    let(:pos_d4) { [4, 3] }
    let(:pos_a6) { [2, 0] }

    it 'should raise an error if the end position is not a valid move' do
      expect { board.validate_end_pos(black_pawn_a7, pos_d4) }.to raise_error('Invalid move for this piece')
    end

    it 'returns nil if no errors are raised' do
      black_pawn = board[black_pawn_a7]
      black_pawn.instance_variable_set(:@moves, { moves: [pos_a6] })
      expect(board.validate_end_pos(black_pawn_a7, pos_a6)).to be_nil
    end
  end

  describe '#move_piece' do
    let(:black_pawn_a7) { [1, 0] }
    let(:pos_a6) { [2, 0] }

    it 'should move a piece from the start position to the end position' do
      black_pawn = board[black_pawn_a7]
      board.move_piece(black_pawn_a7, pos_a6)
      expect(board[pos_a6]).to eq(black_pawn)
    end

    it 'creates a null piece at the start position' do
      board.move_piece(black_pawn_a7, pos_a6)
      expect(board[black_pawn_a7]).to be_a_kind_of(NullPiece)
    end

    it 'should call #update on Piece once' do
      black_pawn = board[black_pawn_a7]
      expect(black_pawn).to receive(:update).once
      board.move_piece(black_pawn_a7, pos_a6)
    end

    it 'should set board.last_move to the end position' do
      board.move_piece(black_pawn_a7, pos_a6)
      expect(board.last_move).to eq(pos_a6)
    end

    context 'if the starting position piece (white pawn) has an en passant move as the ending move' do
      let(:bpa) { Pawn.new(:black, [3, 1]) }
      let(:wpa) { Pawn.new(:white, [3, 2]) }
      let(:wh_pawn_pos) { wpa.pos }
      let(:bl_pawn_pos) { bpa.pos }
      let(:emp) { [2, 1] }
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

      it 'should replace the black pawn position with a null piece' do
        board.instance_variable_set(:@grid, grid)
        wpa.instance_variable_set(:@moves, { en_passant: [emp], castling: [] })
        board.move_piece(wh_pawn_pos, emp)
        expect(board[bl_pawn_pos]).to be_a_kind_of(NullPiece)
      end
    end
  end

  describe '#valid_pos?' do
    context 'when given an array with two indicies' do
      it 'should return true if the pos indicies are between 0 and 7' do
        expect(board.valid_pos?([5, 1])).to be true
      end

      it 'should return false if the pos indicies are not between 0 and 7' do
        expect(board.valid_pos?([-1, -10])).to be false
        expect(board.valid_pos?([8, 99])).to be false
        expect(board.valid_pos?([1, 11])).to be false
        expect(board.valid_pos?([11, 1])).to be false
      end
    end
  end

  describe '#empty?' do
    context 'when given an array with two indicies' do
      it 'should return true if the position is empty' do
        expect(board.empty?([5, 5])).to be true
      end

      it 'should return false if the position is taken by a piece' do
        expect(board.empty?([0, 0])).to be false
      end
    end
  end
end
