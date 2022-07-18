# frozen_string_literal: true

# require 'pieces/step_piece'
require 'pieces/piece'
require 'pieces/king'
require 'board'

describe King do
  let(:board) { instance_double(Board) }
  subject(:bki) { described_class.new(:black, board, [0, 4]) }
  let(:bpc) { instance_double(Piece) }
  let(:npc) { NullPiece.new }
  let(:grid) do
    [
      [npc, npc, npc, npc, bki, npc, npc, npc],
      [npc, npc, npc, npc, npc, npc, npc, npc],
      [npc, npc, npc, npc, npc, npc, npc, npc],
      [npc, npc, npc, npc, npc, npc, npc, npc],
      [npc, npc, npc, npc, npc, npc, npc, npc],
      [npc, npc, npc, npc, npc, npc, npc, npc],
      [npc, npc, npc, npc, npc, npc, npc, npc],
      [npc, npc, npc, npc, npc, npc, npc, npc]
    ]
  end
  
  describe '#moves' do
    context 'when the king has no moves' do

      # moves = [[-1, 4], [-1, 5], [0, 5], [1, 5], [1, 4], [1, 3], [0, 3], [-1, 3]]
      
      before do
        board.instance_variable_set(:@grid, grid)
        allow(board).to receive(:grid).and_return(grid)
        allow(board).to receive(:valid_pos?).and_return(true)
        allow(board).to receive(:[]).and_return(self)
        # allow(npc).to receive(:color)
      end

      it 'returns an empty array' do
        # allow(bki).to receive(:color)
        # allow(board).to receive(:empty?)
        expect(bki.moves).to match_array([[0, 3], [0, 5], [1, 3], [1, 4], [1, 5]])
      end
    end

    it 'should not return any moves that include your own color pieces'

    it 'should not return any moves that are outside of the 8x8 grid'
  end
end
