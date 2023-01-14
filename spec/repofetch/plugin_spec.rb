# frozen_string_literal: true

require 'repofetch'

RSpec.describe Repofetch::Plugin do
  describe '#matches_repo?' do
    it 'raises a NoMethodError' do
      expect { described_class.matches_repo?(nil) }.to raise_error(NoMethodError)
    end
  end

  describe '#from_git' do
    it 'raises a NoMethodError' do
      expect { described_class.from_git(nil, nil) }.to raise_error(NoMethodError)
    end
  end

  describe '#from_args' do
    it 'raises a NoMethodError' do
      expect { described_class.from_args(nil) }.to raise_error(NoMethodError)
    end
  end

  describe '#theme' do
    it 'returns the default theme' do
      expect(described_class.new.theme).to be Repofetch::DEFAULT_THEME
    end
  end

  describe '#ascii' do
    it 'raises a NoMethodError' do
      expect { described_class.new.ascii }.to raise_error(NoMethodError)
    end
  end

  describe '#header' do
    it 'raises a NoMethodError' do
      expect { described_class.new.header }.to raise_error(NoMethodError)
    end
  end

  describe '#separator' do
    let(:plugin) do
      Class.new(described_class) do
        def header
          'header'
        end
      end
    end

    it 'returns a separator with the same visual length as the header' do
      expect(plugin.new.separator).to eq '------'
    end
  end

  describe '#stats' do
    it 'returns an empty array' do
      expect(described_class.new.stats).to eq []
    end
  end
end
