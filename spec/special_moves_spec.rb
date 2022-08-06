# frozen_string_literal: true

require 'special_moves'
require 'board'

describe SpecialMoves do
  subject(:board) { Board.new }

  describe '#en_passant_move?' do
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

  describe '#castling_move?' do
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

  describe '#promotion_move?' do
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

  describe '#king_castling_causes_check' do
    let(:bki) { King.new(:black, [0, 4]) }
    let(:brk) { Rook.new(:black, [0, 7]) }
    let(:wrk) { Rook.new(:white, [7, 5]) }
    let(:last_move) { nil }
    let(:emp) { NullPiece.new }
    let(:grid) do
      [
        [emp, emp, emp, emp, bki, emp, emp, brk],
        [emp, emp, emp, emp, emp, emp, emp, emp],
        [emp, emp, emp, emp, emp, emp, emp, emp],
        [emp, emp, emp, emp, emp, emp, emp, emp],
        [emp, emp, emp, emp, emp, emp, emp, emp],
        [emp, emp, emp, emp, emp, emp, emp, emp],
        [emp, emp, emp, emp, emp, emp, emp, emp],
        [emp, emp, emp, emp, emp, wrk, emp, emp]
      ]
    end
    before { board.instance_variable_set(:@grid, grid) }

    it 'returns false if the king has moved' do
      allow(bki).to receive(:moved).and_return(true)
      allow(bki).to receive(:castling).and_return(true)
      bki.update_moves(grid, last_move)
      expect(board.king_castling_causes_check?(bki.color)).to be false
    end

    context "when the king's castling path causes a check" do
      it 'returns true' do
        allow(bki).to receive(:moved).and_return(false)
        allow(bki).to receive(:castling).and_return(true)
        bki.update_moves(grid, last_move)
        expect(board.king_castling_causes_check?(bki.color)).to be true
      end
    end

    context "when the king's castling path is clear" do
      let(:wrk) { Rook.new(:white, [7, 3]) }
      let(:grid) do
        [
          [emp, emp, emp, emp, bki, emp, emp, brk],
          [emp, emp, emp, emp, emp, emp, emp, emp],
          [emp, emp, emp, emp, emp, emp, emp, emp],
          [emp, emp, emp, emp, emp, emp, emp, emp],
          [emp, emp, emp, emp, emp, emp, emp, emp],
          [emp, emp, emp, emp, emp, emp, emp, emp],
          [emp, emp, emp, emp, emp, emp, emp, emp],
          [emp, emp, emp, wrk, emp, emp, emp, emp]
        ]
      end
      it 'returns false' do
        board.instance_variable_set(:@grid, grid)
        allow(bki).to receive(:moved).and_return(false)
        allow(bki).to receive(:castling).and_return(true)
        bki.update_moves(grid, last_move)
        expect(board.king_castling_causes_check?(bki.color)).to be false
      end
    end
  end

  describe '#castling_path' do
    let(:king) { instance_double(King, row: 7, col: 4) }
    context 'when the rook is king side' do
      let(:rook_column) { 7 }

      it 'returns a an array of positions from the king to rook' do
        expect(board.castling_path(king, rook_column)).to contain_exactly([7, 5], [7, 6])
      end
    end

    context 'when the rook is queen side' do
      let(:rook_column) { 0 }

      it 'returns a an array of positions from the king to rook' do
        expect(board.castling_path(king, rook_column)).to contain_exactly([7, 2], [7, 3])
      end
    end

    context "when the rook is not in it's original column" do
      let(:rook_column) { 5 }

      it 'returns an empty array' do
        expect(board.castling_path(king, rook_column)).to be_empty
      end
    end
  end
end
