# frozen_string_literal: true

require 'repofetch'

RSpec.describe Repofetch::Stat do
  describe '#format_value' do
    it "calls the value's to_s method" do
      stat = described_class.new('label', 'foo')
      expect(stat.format_value).to eq 'foo'
    end
  end

  describe '#to_s' do
    context "when it doesn't have an emoji" do
      let(:stat) { described_class.new('foo', 'bar') }

      it 'is in the format `<label>: <value>`' do
        expect(stat.to_s).to eq 'foo: bar'
      end
    end

    context 'when it has an emoji' do
      let(:stat) { described_class.new('spooky time', 'all the time', emoji: '👻') }

      it 'is in the format `<emoji><label>: <value>`' do
        expect(stat.to_s).to eq '👻spooky time: all the time'
      end
    end
  end
end
