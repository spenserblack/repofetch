# frozen_string_literal: true

require 'repofetch/github'

RSpec.describe Repofetch::Github do
  context 'when the remote is "http://github.com/ghost/boo.git"' do
    let(:remote) { 'http://github.com/ghost/boo.git' }

    describe '#matches_remote?' do
      it 'is true' do
        expect(described_class.matches_remote?(remote)).to be true
      end
    end

    describe '#remote_identifiers' do
      it 'returns ["ghost", "boo"]' do
        expect(described_class.remote_identifiers(remote)).to eq %w[ghost boo]
      end
    end
  end

  context 'when the remote is "https://github.com/ghost/boo.git"' do
    let(:remote) { 'https://github.com/ghost/boo.git' }

    describe '#matches_remote?' do
      it 'is true' do
        expect(described_class.matches_remote?(remote)).to be true
      end
    end

    describe '#remote_identifiers' do
      it 'returns ["ghost", "boo"]' do
        expect(described_class.remote_identifiers(remote)).to eq %w[ghost boo]
      end
    end
  end

  context 'when the remote is "http://github.com/ghost/boo"' do
    let(:remote) { 'http://github.com/ghost/boo' }

    describe '#matches_remote?' do
      it 'is true' do
        expect(described_class.matches_remote?(remote)).to be true
      end
    end

    describe '#remote_identifiers' do
      it 'returns ["ghost", "boo"]' do
        expect(described_class.remote_identifiers(remote)).to eq %w[ghost boo]
      end
    end
  end

  context 'when the remote is "git@github.com:ghost/boo.git"' do
    let(:remote) { 'git@github.com:ghost/boo.git' }

    describe '#matches_remote?' do
      it 'is true' do
        expect(described_class.matches_remote?(remote)).to be true
      end
    end

    describe '#remote_identifiers' do
      it 'returns ["ghost", "boo"]' do
        expect(described_class.remote_identifiers(remote)).to eq %w[ghost boo]
      end
    end
  end

  context 'when the remote is "git@github.com:ghost/boo"' do
    let(:remote) { 'git@github.com:ghost/boo' }

    describe '#matches_remote?' do
      it 'is true' do
        expect(described_class.matches_remote?(remote)).to be true
      end
    end

    describe '#remote_identifiers' do
      it 'returns ["ghost", "boo"]' do
        expect(described_class.remote_identifiers(remote)).to eq %w[ghost boo]
      end
    end
  end

  context 'when the remote is "git@gitlab.com:ghost/boo.git"' do
    let(:remote) { 'git@gitlab.com:ghost/boo.git' }

    describe '#matches_remote?' do
      it 'is true' do
        expect(described_class.matches_remote?(remote)).to be false
      end
    end
  end

  context 'when the remote is "git@gitlab.com:ghost/boo"' do
    let(:remote) { 'git@gitlab.com:ghost/boo' }

    describe '#matches_remote?' do
      it 'is false' do
        expect(described_class.matches_remote?(remote)).to be false
      end
    end
  end
end
