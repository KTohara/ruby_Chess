# frozen_string_literal: true

require 'utility/save_load'
require 'game'

describe SaveLoad do
  let(:test_class) { Game.new }
  let(:board) { 'test' }

  before { test_class.instance_variable_set(:@board, board) }

  # after(:all) { File.delete(File.join(Dir.pwd, '/save_states/test.yaml')) }

  describe '#save_game' do
    before do
      allow(test_class).to receive(:puts)
    end

    it 'dumps the file' do
      allow(File).to receive(:write)
      allow(test_class).to receive(:exit)
      expect(YAML).to receive(:dump)
      test_class.save_game
    end

    it 'saves the file' do
      expect(File).to receive(:write)
      allow(test_class).to receive(:exit)
      test_class.save_game
    end

    it 'exits after saving' do
      allow(File).to receive(:write)
      expect(test_class).to receive(:exit)
      test_class.save_game
    end
  end

  describe '#load_game' do
    before do
      allow(test_class).to receive(:puts)
      allow(test_class).to receive(:exit)
      test_class.save_game('test')
    end

    it 'loads the game' do
      expect(YAML).to receive(:safe_load)
      test_class.load_game('test.yaml')
    end

    it 'deletes the file' do
      expect(File).to receive(:delete)
      test_class.load_game('test.yaml')
    end

    it 'preserves the game' do
      game = test_class.load_game('test.yaml')
      expect(game.board).to eq(board)
    end
  end
end
