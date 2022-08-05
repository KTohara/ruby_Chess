# frozen_string_literal: true

require 'game'

describe Game do
  subject(:game) { described_class.new }

  describe '#play' do
    context 'when the game finishes in one turn' do
      it 'loops the game one time' do
        allow(game).to receive(:game_over?).and_return(false, true)
        allow(game).to receive(:game_result)
        expect(game).to receive(:play_turn).once
        game.play
      end
    end

    context 'when the game ends' do
      it 'returns the game results' do
        allow(game).to receive(:game_over?).and_return(true)
        expect(game).to receive(:game_result)
        game.play
      end
    end
  end

  describe '#check_special_inputs' do
    it 'saves the game if the input is :save' do
      expect(game).to receive(:save_game)
      game.check_special_inputs(:save)
    end

    it 'resigns the game if the input is :resign' do
      expect(game).to receive(:resign_game)
      game.check_special_inputs(:resign)
    end
  end

  describe '#switch_player' do
    it 'switches the current player from white to black, and black to white' do
      expect { game.switch_player }.to change { game.turn_color }.from(:white).to(:black)
      expect { game.switch_player }.to change { game.turn_color }.from(:black).to(:white)
    end
  end

  describe '#board_check_notification' do
    it 'sets a notification when board is in check' do
      allow(game.board).to receive(:check?).and_return(true)
      expect { game.board_check_notifications }.to change { game.notifications }
    end

    it 'resets notifications when board is not in check' do
      game.notifications[:notifications] = 'test_message'
      allow(game.board).to receive(:check?).and_return(false)
      expect { game.board_check_notifications }.to change { game.notifications[:notifications] }.from('test_message').to(nil)
    end
  end

  describe '#game_over' do
    it 'sends board #checkmate?' do
      expect(game.board).to receive(:checkmate?)
      game.game_over?
    end

    it 'sends board #insufficient_material?' do
      expect(game.board).to receive(:insufficient_material?)
      game.game_over?
    end
  end

  describe '#resign_game' do
    it "exits the game when the input parameter is 'y'" do
      allow(game).to receive(:render)
      allow(game).to receive(:puts)
      expect(game).to receive(:exit)
      game.resign_game('y')
    end

    it "resumes the game when the input parameter is 'n'" do
      allow(game).to receive(:render)
      allow(game).to receive(:puts)
      expect(game).to receive(:play_turn)
      game.resign_game('n')
    end
  end
end
