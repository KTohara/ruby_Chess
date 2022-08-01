# frozen_string_literal: true

require 'pieces/piece'
require 'pieces/nullpiece'

describe Piece do
  subject(:piece) { described_class.new(:white, [5, 5]) }
  describe '#valid_location?' do
    it 'returns true if position indices are between 0 and 7' do
      expect(piece).to be_valid_location([1, 5])
    end

    it 'returns false if position indices are not between 0 and 7' do
      expect(piece).not_to be_valid_location([-1, 5])
      expect(piece).not_to be_valid_location([1, -5])
      expect(piece).not_to be_valid_location([10, 5])
      expect(piece).not_to be_valid_location([5, 10])
    end
  end

  describe '#enemy?' do
    let(:enemy) { described_class.new(:black, [3, 3]) }
    let(:ally) { described_class.new(:white, [3, 3]) }
    let(:empty) { instance_double(NullPiece, color: :none) }
    it 'returns true if the piece given as an argument is an opposing color to itself' do
      expect(piece.enemy?(enemy)).to be true
    end

    it 'returns false if the piece given as an argument is the same color as itself' do
      expect(piece.enemy?(ally)).to be false
    end

    it 'returns false if the piece given as an argument has :none (empty) as the color' do
      expect(piece.enemy?(empty)).to be false
    end
  end

  describe '#list_all_moves' do
    it "returns a nested array of the piece's @moves hash" do
      piece.instance_variable_set(:@moves, { moves: [[1, 2], [3, 4], [5, 6]], captures: [[3, 1]] })
      expect(piece.list_all_moves).to eq([[1, 2], [3, 4], [5, 6], [3, 1]])
    end

    it 'returns an empty array when there are no moves' do
      piece.instance_variable_set(:@moves, {})
      expect(piece.list_all_moves).to be_empty
    end
  end

  describe '#list_all_captures' do
    before { piece.instance_variable_set(:@moves, { moves: [[1, 2]], captures: [[3, 1]], en_passant: [[4, 6]] }) }
    it "returns a nested array of the piece's captures from the @moves hash" do
      expect(piece.list_all_captures).to eq([[3, 1], [4, 6]])
    end

    it 'will only return moves from the hash that are :captures or :en_passant' do
      expect(piece.list_all_captures).not_to include([1, 2])
    end
  end
end
