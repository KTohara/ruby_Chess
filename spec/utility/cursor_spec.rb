# frozen_string_literal: true

require 'utility/cursor'

describe Cursor do
  subject(:cursor) { described_class.new([4, 4]) }
  let(:up_key) { "\e[A" }
  let(:down_key) { "\e[B" }
  let(:right_key) { "\e[C" }
  let(:left_key) { "\e[D" }
  let(:ctrl_c) { "\u0003" }
  let(:space) { ' ' }
  let(:enter) { "\r" }
  let(:b_key) { 'b' }
  let(:r_key) { 'r' }

  describe '#key_input' do
    context 'when the key press is a direction' do
      it "updates the direction when the 'up' key is pressed" do
        expect { cursor.key_input(up_key) }.to change { cursor.cursor_pos }.to([3, 4])
      end

      it "updates the direction when the 'down' key is pressed" do
        expect { cursor.key_input(down_key) }.to change { cursor.cursor_pos }.to([5, 4])
      end

      it "updates the direction when the 'right' key is pressed" do
        expect { cursor.key_input(right_key) }.to change { cursor.cursor_pos }.to([4, 5])
      end

      it "updates the direction when the 'left' key is pressed" do
        expect { cursor.key_input(left_key) }.to change { cursor.cursor_pos }.to([4, 3])
      end

      it 'returns nil' do
        expect(cursor.key_input(up_key)).to be_nil
        expect(cursor.key_input(down_key)).to be_nil
        expect(cursor.key_input(right_key)).to be_nil
        expect(cursor.key_input(left_key)).to be_nil
      end
    end

    context 'when a direction is pressed that puts the cursor out of bounds' do
      it 'will not update the column position below 0 or beyond 7' do
        expect { 10.times { cursor.key_input(right_key) } }.to change { cursor.cursor_pos }.to([4, 7])
        expect { 10.times { cursor.key_input(left_key) } }.to change { cursor.cursor_pos }.to([4, 0])
      end

      it 'will not update the row position below 0 or beyond 7' do
        expect { 10.times { cursor.key_input(down_key) } }.to change { cursor.cursor_pos }.to([7, 4])
        expect { 10.times { cursor.key_input(up_key) } }.to change { cursor.cursor_pos }.to([0, 4])
      end
    end

    context "when 'return' or 'space' is pressed" do
      it "will toggle @selected to it's opposite boolean" do
        expect { cursor.key_input(space) }.to change { cursor.selected }.from(false).to(true)
        expect { cursor.key_input(space) }.to change { cursor.selected }.from(true).to(false)
        expect { cursor.key_input(enter) }.to change { cursor.selected }.from(false).to(true)
        expect { cursor.key_input(enter) }.to change { cursor.selected }.from(true).to(false)
      end

      it 'will return the cursor position' do
        expect(cursor.key_input(enter)).to eq(cursor.cursor_pos)
        expect(cursor.key_input(space)).to eq(cursor.cursor_pos)
      end
    end

    context "when 'ctrl-c' is pressed" do
      it 'should exit the game cleanly' do
        expect { cursor.key_input(ctrl_c) }.to raise_error(SystemExit)
      end
    end

    context "when 'b' is pressed" do
      it 'should return :save' do
        expect(cursor.key_input(b_key)).to eq(:save)
      end
    end

    context "when 'r' is pressed" do
      it 'should return :resign' do
        expect(cursor.key_input(r_key)).to eq(:resign)
      end
    end
  end
end
