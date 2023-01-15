# frozen_string_literal: true

require 'dotenv'
require 'repofetch/env'

RSpec.describe Repofetch::Env do
  describe '#load' do
    before { allow(Dotenv).to receive(:load) }

    it 'loads from ~/.repofetch.env' do
      described_class.load
      expect(Dotenv).to have_received(:load).with(File.expand_path('.repofetch.env', Dir.home))
    end

    it 'loads from ~/repofetch.env' do
      described_class.load
      expect(Dotenv).to have_received(:load).with(File.expand_path('repofetch.env', Dir.home))
    end
  end
end
