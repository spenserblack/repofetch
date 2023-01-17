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

  describe '#agent' do
    context 'when the token is set' do
      let(:agent) { instance_double(Sawyer::Agent) }
      let(:connection) { instance_double(Faraday::Connection, headers: {}) }
      let(:instance) { described_class.new('foo/bar') }

      before do
        allow(instance).to receive(:token).and_return('abc123')
        allow(Sawyer::Agent).to receive(:new) do |&block|
          block.call(connection)
          agent
        end
      end

      it 'sets the Authorization header' do
        instance.agent

        expect(connection.headers['Authorization']).to eq 'Bearer abc123'
      end
    end
  end

  describe '#token' do
    before { allow(ENV).to receive(:fetch).with('BITBUCKET_TOKEN', nil).and_return('abc123') }

    it 'returns the value of the BITBUCKET_TOKEN environment variable' do
      expect(described_class.new('foo/bar').token).to eq 'abc123'
    end
  end

  describe '#matches_repo?' do
    let(:git) { instance_double(Git::Base) }
    let(:origin_url) { 'https://bitbucket.org/foo/bar.git' }
    let(:origin) { instance_double(Git::Remote, url: origin_url) }

    before do
      allow(Repofetch).to receive(:default_remote).and_return(origin)
      allow(described_class).to receive(:matches_remote?).with(origin_url).and_return(true)
    end

    it 'calls #matches_remote? with the default remote URL' do
      described_class.matches_repo?(git)

      expect(described_class).to have_received(:matches_remote?).with(origin_url)
    end
  end
end
