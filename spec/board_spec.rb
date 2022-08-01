# frozen_string_literal: true

require 'board'
require 'special_moves'
require 'messages'

# include Messages

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

      it 'should raise an error when the position is not within the 8x8 grid' do
        expect { board[invalid_pos] }.to raise_error(Messages::PositionError.new.message)
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

      it 'should raise an error when the position is not within the 8x8 grid' do
        expect { board[invalid_pos] = pawn }.to raise_error(Messages::PositionError.new.message)
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
      expect { board.validate_start_pos(turn_color, pos_d4) }.to raise_error(Messages::SquareError.new.message)
    end

    it "should raise an error if the start position is the opponent's piece" do
      expect { board.validate_start_pos(turn_color, black_pawn_a7) }.to raise_error(Messages::OpponentError.new.message)
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
      expect { board.validate_end_pos(black_pawn_a7, pos_d4, turn_color) }.to raise_error(Messages::MoveError.new.message)
    end

    it 'returns nil if no errors are raised' do
      black_pawn = board[black_pawn_a7]
      black_pawn.instance_variable_set(:@moves, { moves: [pos_a6] })
      expect(board.validate_end_pos(black_pawn_a7, pos_a6, turn_color)).to be_nil
    end

    context 'when the move causes a king to be put in check' do
      let(:bki) { King.new(:black, [7, 6]) }
      let(:wrk) { Rook.new(:white, [0, 7]) }
      let(:emp) { NullPiece.new }
      let(:turn_color) { :black }
      let(:grid) do
        [
          [emp, emp, emp, emp, emp, emp, emp, wrk],
          [emp, emp, emp, emp, emp, emp, emp, emp],
          [emp, emp, emp, emp, emp, emp, emp, emp],
          [emp, emp, emp, emp, emp, emp, emp, emp],
          [emp, emp, emp, emp, emp, emp, emp, emp],
          [emp, emp, emp, emp, emp, emp, emp, emp],
          [emp, emp, emp, emp, emp, emp, emp, emp],
          [emp, emp, emp, emp, emp, emp, bki, emp]
        ]
      end

      it 'raises an error' do
        black_king_g1 = [7, 6]
        check_pos_h1 = [7, 7]
        board.instance_variable_set(:@grid, grid)
        bki.instance_variable_set(:@moves, { moves: [check_pos_h1] })
        expect { board.validate_end_pos(black_king_g1, check_pos_h1, turn_color) }.to raise_error(Messages::CheckError.new.message)
      end
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

    context 'if the starting position piece (white king) can king side castle' do
      let(:wki) { King.new(:white, [7, 4]) }
      let(:wrk) { Rook.new(:white, [7, 7]) }
      let(:castling_start_pos) { [7, 6] }
      let(:castling_end_pos) { [7, 4] }
      let(:emp) { NullPiece.new }
      let(:grid) do
        [
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, wki, emp, emp, wrk]
        ]
      end

      before do
        board.instance_variable_set(:@grid, grid)
        wki.instance_variable_set(:@moves, { castling: [castling_start_pos] })
        board.move_piece(wki.pos, castling_start_pos)
      end

      it 'should place the white king at position [7, 6]' do
        expect(wki.pos).to eq(castling_start_pos)
      end

      it 'should replace the king with a null piece at position [7, 4]' do
        expect(board[castling_end_pos]).to be_a_kind_of(NullPiece)
      end
    end

    context 'if the starting position piece (black king) can queen side castle' do
      let(:bki) { King.new(:black, [0, 4]) }
      let(:brk) { Rook.new(:black, [0, 0]) }
      let(:emp) { NullPiece.new }
      let(:grid) do
        [
          [brk, emp, emp, emp, bki, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil]
        ]
      end

      before do
        board.instance_variable_set(:@grid, grid)
        bki.instance_variable_set(:@moves, { castling: [[0, 2]] })
        board.move_piece(bki.pos, [0, 2])
      end

      it 'should place the black king at position [0, 2]' do
        expect(bki.pos).to eq([0, 2])
      end

      it 'should replace the king with a null piece at position [0, 4]' do
        expect(board[[0, 4]]).to be_a_kind_of(NullPiece)
      end
    end
  end

  describe '#en_passant_move' do
    context 'if the starting position piece (white pawn) has an en passant move as the ending move' do
      let(:bpa) { Pawn.new(:black, [3, 1]) }
      let(:wpa) { Pawn.new(:white, [3, 2]) }
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
        wpa.instance_variable_set(:@moves, { en_passant: [[2, 1]] })
        board.en_passant_move(wpa, emp)
        expect(board[bpa.pos]).to be_a_kind_of(NullPiece)
      end
    end
  end

  describe '#castling_move' do
    context 'if the starting position piece (white king) can king side castle' do
      let(:wki) { King.new(:white, [7, 4]) }
      let(:wrk) { Rook.new(:white, [7, 7]) }
      let(:emp) { NullPiece.new }
      let(:castling_pos) { [7, 6] }
      let(:grid) do
        [
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, wki, emp, emp, wrk]
        ]
      end

      before do
        board.instance_variable_set(:@grid, grid)
        wki.instance_variable_set(:@moves, { castling: [castling_pos] })
      end

      it 'should place the right white rook at position [7, 5]' do
        board.castling_move(castling_pos)
        expect(wrk.pos).to eq([7, 5])
      end

      it 'should replace the rook with a null piece at position [7, 7]' do
        board.castling_move(castling_pos)
        expect(board[[7, 7]]).to be_a_kind_of(NullPiece)
      end

      it 'should call #update on the rook' do
        expect(wrk).to receive(:update).once
        board.castling_move(castling_pos)
      end
    end

    context 'if the starting position piece (black king) can queen side castle' do
      let(:bki) { King.new(:black, [0, 4]) }
      let(:brk) { Rook.new(:black, [0, 0]) }
      let(:emp) { NullPiece.new }
      let(:castling_pos) { [0, 2] }
      let(:grid) do
        [
          [brk, emp, emp, emp, bki, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil],
          [nil, nil, nil, nil, nil, nil, nil, nil]
        ]
      end

      before do
        board.instance_variable_set(:@grid, grid)
        bki.instance_variable_set(:@moves, { castling: [castling_pos] })
      end

      it 'should place the left black rook at position [0, 3]' do
        board.castling_move(castling_pos)
        expect(brk.pos).to eq([0, 3])
      end

      it 'should replace the rook with a null piece at position [0, 0]' do
        board.castling_move(castling_pos)
        expect(board[[0, 0]]).to be_a_kind_of(NullPiece)
      end

      it 'should call #update on the rook' do
        expect(brk).to receive(:update).once
        board.castling_move(castling_pos)
      end
    end
  end

  describe '#promotion_move' do
    let(:pawn) { Pawn.new(:black, [7, 3]) }
    let(:pawn_position) { board[pawn.pos] }
    let(:pawn_color) { board[pawn.pos].color }

    it 'should replace/promote the pawn' do
      board.promotion_move(pawn, 1)
      expect(pawn_position).not_to eq(pawn)
    end

    it 'when input is 1, replaces the piece with a Rook' do
      board.promotion_move(pawn, 1)
      expect(pawn_position).to be_a_kind_of(Rook)
    end

    it 'when input is 2, replaces the piece with a Knight' do
      board.promotion_move(pawn, 2)
      expect(pawn_position).to be_a_kind_of(Knight)
    end

    it 'when input is 3, replaces the piece with a Bishop' do
      board.promotion_move(pawn, 3)
      expect(pawn_position).to be_a_kind_of(Bishop)
    end

    it 'when input is 4, replaces the piece with a Queen' do
      board.promotion_move(pawn, 4)
      expect(pawn_position).to be_a_kind_of(Queen)
    end

    it 'does not change the color of piece' do
      board.promotion_move(pawn, 4)
      expect(pawn_color).to eq(:black)
    end
  end

  describe 'en_passant_move?' do
    let(:pawn) { instance_double(Pawn) }
    let(:valid_en_passant_move) { [2, 3] }
    let(:invalid_en_passant_move) { [0, 0] }

    before { allow(pawn).to receive(:moves).and_return({ en_passant: [valid_en_passant_move] }) }

    it 'returns true if the pawn has an en passant move' do
      expect(board).to be_en_passant_move(pawn, valid_en_passant_move)
    end

    it 'returns false if the pawn does not have an en passant move' do
      expect(board).not_to be_en_passant_move(pawn, invalid_en_passant_move)
    end
  end

  describe 'castling_move?' do
    let(:king) { instance_double(King) }
    let(:valid_castling_move) { [7, 6] }
    let(:invalid_castling_move) { [4, 4] }

    before { allow(king).to receive(:moves).and_return({ castling: [valid_castling_move] }) }

    it 'returns true if the king has a castling move' do
      expect(board).to be_castling_move(king, valid_castling_move)
    end

    it 'returns false if the king does not have a castling move' do
      expect(board).not_to be_castling_move(king, invalid_castling_move)
    end
  end

  describe 'promotion_move?' do
    let(:pawn) { instance_double(Pawn, color: :white) }
    let(:valid_promotion_move) { [0, 7] }
    let(:invalid_promotion_move) { [4, 4] }

    it 'returns true if the pawn has a promotion move' do
      allow(pawn).to receive(:instance_of?).with(Pawn).and_return(true)
      allow(pawn).to receive(:promotable?).and_return(true)
      expect(board).to be_promotion_move(pawn)
    end

    it 'returns false if the pawn does not have a promotion move' do
      allow(pawn).to receive(:instance_of?).with(Pawn).and_return(true)
      allow(pawn).to receive(:promotable?).and_return(false)
      expect(board).not_to be_promotion_move(pawn)
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

  describe '#check?' do
    let(:bki) { King.new(:black, [7, 7]) }
    let(:emp) { NullPiece.new }
    let(:turn_color) { :black }

    context "when a player can capture the opponent's king in the next turn" do
      let(:wqn) { Queen.new(:white, [5, 7]) }
      let(:grid) do
        [
          [emp, emp, emp, emp, emp, emp, emp, emp],
          [emp, emp, emp, emp, emp, emp, emp, emp],
          [emp, emp, emp, emp, emp, emp, emp, emp],
          [emp, emp, emp, emp, emp, emp, emp, emp],
          [emp, emp, emp, emp, emp, emp, emp, emp],
          [emp, emp, emp, emp, emp, emp, emp, wqn],
          [emp, emp, emp, emp, emp, emp, emp, emp],
          [emp, emp, emp, emp, emp, emp, emp, bki]
        ]
      end
      it 'returns true' do
        board.instance_variable_set(:@grid, grid)
        expect(board.check?(turn_color)).to be true
      end
    end

    context "when a player cannot capture the opponent's king in the next turn" do
      let(:wqn) { Queen.new(:white, [5, 6]) }
      let(:grid) do
        [
          [emp, emp, emp, emp, emp, emp, emp, emp],
          [emp, emp, emp, emp, emp, emp, emp, emp],
          [emp, emp, emp, emp, emp, emp, emp, emp],
          [emp, emp, emp, emp, emp, emp, emp, emp],
          [emp, emp, emp, emp, emp, emp, emp, emp],
          [emp, emp, emp, emp, emp, emp, wqn, emp],
          [emp, emp, emp, emp, emp, emp, emp, emp],
          [emp, emp, emp, emp, emp, emp, emp, bki]
        ]
      end
      it 'returns false' do
        board.instance_variable_set(:@grid, grid)
        expect(board.check?(turn_color)).to be false
      end
    end
  end

  describe '#checkmate?' do
    let(:bki) { King.new(:black, [7, 7]) }
    let(:emp) { NullPiece.new }
    let(:turn_color) { :black }

    context 'when a player is in checkmate' do
      let(:wqn) { Queen.new(:white, [7, 5]) }
      let(:wrk) { Rook.new(:white, [5, 7]) }
      let(:grid) do
        [
          [emp, emp, emp, emp, emp, emp, emp, emp],
          [emp, emp, emp, emp, emp, emp, emp, emp],
          [emp, emp, emp, emp, emp, emp, emp, emp],
          [emp, emp, emp, emp, emp, emp, emp, emp],
          [emp, emp, emp, emp, emp, emp, emp, emp],
          [emp, emp, emp, emp, emp, emp, emp, wrk],
          [emp, emp, emp, emp, emp, emp, emp, emp],
          [emp, emp, emp, emp, emp, wqn, emp, bki]
        ]
      end
      it "returns true if the player's king cannot escape a capture" do
        board.instance_variable_set(:@grid, grid)
        expect(board.checkmate?(turn_color)).to be true
      end

      it "returns false if the player's king can escape a capture" do
        board.instance_variable_set(:@grid, grid)
        queen_f1 = [7, 5]
        queen_f3 = [7, 3]
        board.move_piece(queen_f1, queen_f3)
        expect(board.checkmate?(turn_color)).to be false
      end
    end
  end
end
