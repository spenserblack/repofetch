# frozen_string_literal: true

require 'git'
require 'repofetch'
require 'repofetch/gitlab'
require 'sawyer'

RSpec.describe Repofetch::Gitlab do
  context 'when the remote is "http://gitlab.com/gitlab-org/gitlab.git"' do
    let(:remote) { 'http://gitlab.com/gitlab-org/gitlab.git' }

    describe '#matches_remote?' do
      it 'is true' do
        expect(described_class.matches_remote?(remote)).to be true
      end
    end

    describe '#remote_identifier' do
      it 'returns "gitlab-org/gitlab"' do
        expect(described_class.remote_identifier(remote)).to eq 'gitlab-org/gitlab'
      end
    end
  end

  context 'when the remote is "https://gitlab.com/gitlab-org/gitlab.git"' do
    let(:remote) { 'https://gitlab.com/gitlab-org/gitlab.git' }

    describe '#matches_remote?' do
      it 'is true' do
        expect(described_class.matches_remote?(remote)).to be true
      end
    end

    describe '#remote_identifier' do
      it 'returns "gitlab-org/gitlab"' do
        expect(described_class.remote_identifier(remote)).to eq 'gitlab-org/gitlab'
      end
    end
  end

  context 'when the remote is "http://gitlab.com/gitlab-org/gitlab"' do
    let(:remote) { 'http://gitlab.com/gitlab-org/gitlab' }

    describe '#matches_remote?' do
      it 'is true' do
        expect(described_class.matches_remote?(remote)).to be true
      end
    end

    describe '#remote_identifier' do
      it 'returns "gitlab-org/gitlab"' do
        expect(described_class.remote_identifier(remote)).to eq 'gitlab-org/gitlab'
      end
    end
  end

  context 'when the remote is "git@gitlab.com:gitlab-org/gitlab.git"' do
    let(:remote) { 'git@gitlab.com:gitlab-org/gitlab.git' }

    describe '#matches_remote?' do
      it 'is true' do
        expect(described_class.matches_remote?(remote)).to be true
      end
    end

    describe '#remote_identifier' do
      it 'returns "gitlab-org/gitlab"' do
        expect(described_class.remote_identifier(remote)).to eq 'gitlab-org/gitlab'
      end
    end
  end

  context 'when the remote is "git@gitlab.com:gitlab-org/gitlab"' do
    let(:remote) { 'git@gitlab.com:gitlab-org/gitlab' }

    describe '#matches_remote?' do
      it 'is true' do
        expect(described_class.matches_remote?(remote)).to be true
      end
    end

    describe '#remote_identifier' do
      it 'returns "gitlab-org/gitlab"' do
        expect(described_class.remote_identifier(remote)).to eq 'gitlab-org/gitlab'
      end
    end
  end

  context 'when the remote is "git@github.com:ghost/boo.git"' do
    let(:remote) { 'git@github.com:ghost/boo.git' }

    describe '#matches_remote?' do
      it 'is true' do
        expect(described_class.matches_remote?(remote)).to be false
      end
    end
  end

  context 'when the remote is "git@github.com:ghost/boo"' do
    let(:remote) { 'git@github.com:ghost/boo' }

    describe '#matches_remote?' do
      it 'is false' do
        expect(described_class.matches_remote?(remote)).to be false
      end
    end
  end

  describe '#matches_repo?' do
    let(:git) { instance_double(Git::Base) }
    let(:origin_url) { 'https://gitlab.com/foo/bar.git' }
    let(:origin) { instance_double(Git::Remote) }

    before do
      allow(origin).to receive(:url).and_return(origin_url)
      allow(Repofetch).to receive(:default_remote).and_return(origin)
      allow(described_class).to receive(:matches_remote?).and_return(true)
    end

    it 'calls #matches_remote? with the default remote URL' do
      described_class.matches_repo?(git)

      expect(described_class).to have_received(:matches_remote?).with(origin_url)
    end
  end

  describe '#repo_identifier' do
    let(:git) { instance_double(Git::Base) }
    let(:origin_url) { 'https://gitlab.com/foo/bar.git' }
    let(:origin) { instance_double(Git::Remote) }

    before do
      allow(origin).to receive(:url).and_return(origin_url)
      allow(Repofetch).to receive(:default_remote).and_return(origin)
      allow(described_class).to receive(:remote_identifier)
    end

    it 'calls #remote_identifier with the default remote URL' do
      described_class.repo_identifier(git)

      expect(described_class).to have_received(:remote_identifier).with(origin_url)
    end
  end

  describe '#token' do
    before { allow(ENV).to receive(:fetch).with('GITLAB_TOKEN', nil).and_return('abc123') }

    it 'returns the value of the GITLAB_TOKEN environment variable' do
      expect(described_class.new('1').token).to eq 'abc123'
    end
  end

  describe '#agent' do
    context 'when the token is set' do
      let(:agent) { instance_double(Sawyer::Agent) }
      let(:connection) { instance_double(Faraday::Connection) }
      let(:headers) { {} }
      let(:instance) { described_class.new('1') }

      before do
        allow(instance).to receive(:token).and_return('abc123')
        allow(connection).to receive(:headers).and_return(headers)
        allow(Sawyer::Agent).to receive(:new) do |&block|
          block.call(connection)
          agent
        end
      end

      it 'sets the Authorization header' do
        instance.agent

        expect(headers['Authorization']).to eq 'Bearer abc123'
      end
    end
  end
end
