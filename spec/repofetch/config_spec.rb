# frozen_string_literal: true

require 'repofetch/config'

RSpec.describe Repofetch::Config do
  describe '#load' do
    it 'calls #new with the contents of the given file' do
      allow(File).to receive(:read).and_return('plugins: []')
      described_class.load
      expect(File).to have_received(:read).with(described_class.path)
    end
  end

  describe '#load!' do
    context 'when the file exists at the given path' do
      before do
        allow(File).to receive(:exist?).and_return(true)
        allow(File).to receive(:read).and_return('plugins: []')
        allow(File).to receive(:write)
      end

      it 'calls #new with the contents' do
        described_class.load!
        expect(File).to have_received(:read).with(described_class.path)
      end

      it 'does not write the default config' do
        described_class.load!
        expect(File).not_to have_received(:write)
      end
    end

    context 'when the file does not exist at the given path' do
      before do
        allow(File).to receive(:exist?).and_return(false)
        allow(File).to receive(:read).and_return('plugins: []')
        allow(File).to receive(:write)
      end

      it 'writes the default config' do
        described_class.load!
        expect(File).to have_received(:write).with(described_class.path, described_class::DEFAULT_CONFIG)
      end

      it 'calls #new with the default config' do
        allow(described_class).to receive(:new).and_call_original
        described_class.load!
        expect(described_class).to have_received(:new).with(described_class::DEFAULT_CONFIG)
      end
    end
  end

  describe '#[]' do
    let(:contents) { 'plugins: [foo]' }

    it 'returns the value for the given key' do
      config = described_class.new(contents)
      expect(config[:plugins]).to eq(['foo'])
    end
  end
end
