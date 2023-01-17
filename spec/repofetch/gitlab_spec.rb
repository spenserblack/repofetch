# frozen_string_literal: true

require 'git'
require 'repofetch'
require 'repofetch/exceptions'
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
    let(:origin) { instance_double(Git::Remote, url: origin_url) }

    before do
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
    let(:origin) { instance_double(Git::Remote, url: origin_url) }

    before do
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
      let(:connection) { instance_double(Faraday::Connection, headers: {}) }
      let(:instance) { described_class.new('1') }

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

  describe '#from_git' do
    let(:git) { instance_double(Git::Base) }
    let(:instance) { instance_double(described_class) }

    before do
      allow(described_class).to receive(:new).and_return(instance)
      allow(described_class).to receive(:repo_identifier).and_return('foo/bar')
    end

    context 'when no CLI args are given' do
      let(:args) { [] }

      it 'creates a new instance with the repo identifier' do
        expect(described_class.from_git(git, args)).to eq instance
      end
    end

    context 'when one or more CLI args are given' do
      let(:args) { ['abc/xyz'] }

      it 'raises a PluginUsageError' do
        expect { described_class.from_git(git, args) }.to raise_error(Repofetch::PluginUsageError)
      end
    end
  end

  describe '#from_args' do
    let(:instance) { instance_double(described_class) }

    before do
      allow(described_class).to receive(:new).and_return(instance)
    end

    context 'when no CLI args are given' do
      let(:args) { [] }

      it 'raises a PluginUsageError' do
        expect { described_class.from_args(args) }.to raise_error(Repofetch::PluginUsageError)
      end
    end

    context 'when one CLI arg is given' do
      let(:args) { ['foo/bar'] }

      it 'creates a new instance with the repo identifier' do
        expect(described_class.from_args(args)).to eq instance
      end
    end

    context 'when two or more CLI args are given' do
      let(:args) { ['foo/bar', 'abc/xyz'] }

      it 'raises a PluginUsageError' do
        expect { described_class.from_args(args) }.to raise_error(Repofetch::PluginUsageError)
      end
    end
  end
end
