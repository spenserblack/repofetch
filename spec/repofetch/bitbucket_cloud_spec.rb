# frozen_string_literal: true

require 'repofetch/bitbucketcloud'

RSpec.describe Repofetch::BitbucketCloud do
  context 'when the remote is "http://bitbucket.org/foo/bar.git"' do
    let(:remote) { 'http://bitbucket.org/foo/bar.git' }

    describe '#matches_remote?' do
      it 'is true' do
        expect(described_class.matches_remote?(remote)).to be true
      end
    end

    describe '#remote_identifiers' do
      it 'returns ["foo", "bar"]' do
        expect(described_class.remote_identifiers(remote)).to eq %w[foo bar]
      end
    end
  end

  context 'when the remote is "https://bitbucket.org/foo/bar.git"' do
    let(:remote) { 'https://bitbucket.org/foo/bar.git' }

    describe '#matches_remote?' do
      it 'is true' do
        expect(described_class.matches_remote?(remote)).to be true
      end
    end

    describe '#remote_identifiers' do
      it 'returns ["foo", "bar"]' do
        expect(described_class.remote_identifiers(remote)).to eq %w[foo bar]
      end
    end
  end

  context 'when the remote is "http://bitbucket.org/foo/bar"' do
    let(:remote) { 'http://bitbucket.org/foo/bar' }

    describe '#matches_remote?' do
      it 'is true' do
        expect(described_class.matches_remote?(remote)).to be true
      end
    end

    describe '#remote_identifiers' do
      it 'returns ["foo", "bar"]' do
        expect(described_class.remote_identifiers(remote)).to eq %w[foo bar]
      end
    end
  end

  context 'when the remote is "git@bitbucket.org:foo/bar.git"' do
    let(:remote) { 'git@bitbucket.org:foo/bar.git' }

    describe '#matches_remote?' do
      it 'is true' do
        expect(described_class.matches_remote?(remote)).to be true
      end
    end

    describe '#remote_identifiers' do
      it 'returns ["foo", "bar"]' do
        expect(described_class.remote_identifiers(remote)).to eq %w[foo bar]
      end
    end
  end

  context 'when the remote is "git@bitbucket.org:foo/bar"' do
    let(:remote) { 'git@bitbucket.org:foo/bar' }

    describe '#matches_remote?' do
      it 'is true' do
        expect(described_class.matches_remote?(remote)).to be true
      end
    end

    describe '#remote_identifiers' do
      it 'returns ["foo", "bar"]' do
        expect(described_class.remote_identifiers(remote)).to eq %w[foo bar]
      end
    end
  end

  context 'when the remote is "git@gitlab.com:foo/bar.git"' do
    let(:remote) { 'git@gitlab.com:foo/bar.git' }

    describe '#matches_remote?' do
      it 'is true' do
        expect(described_class.matches_remote?(remote)).to be false
      end
    end
  end

  context 'when the remote is "git@gitlab.com:foo/bar"' do
    let(:remote) { 'git@gitlab.com:foo/bar' }

    describe '#matches_remote?' do
      it 'is false' do
        expect(described_class.matches_remote?(remote)).to be false
      end
    end
  end
end
