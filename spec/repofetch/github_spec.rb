# frozen_string_literal: true

require 'git'
require 'repofetch'
require 'repofetch/exceptions'
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

  describe '#repo_id' do
    it 'returns OWNER/REPO' do
      expect(described_class.new('ghost', 'boo').repo_id).to eq 'ghost/boo'
    end
  end

  describe 'matches_repo?' do
    let(:git) { instance_double(Git::Base) }
    let(:origin_url) { 'https://github.com/ghost/boo.git' }
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

  describe '#repo_identifiers' do
    let(:git) { instance_double(Git::Base) }
    let(:origin_url) { 'https://github.com/ghost/boo.git' }
    let(:origin) { instance_double(Git::Remote, url: origin_url) }

    before do
      allow(Repofetch).to receive(:default_remote).and_return(origin)
      allow(described_class).to receive(:remote_identifiers).and_return(%w[ghost boo])
    end

    it 'calls #remote_identifiers with the default remote URL' do
      described_class.repo_identifiers(git)
      expect(described_class).to have_received(:remote_identifiers).with(origin_url)
    end
  end

  describe '#from_git' do
    let(:git) { instance_double(Git::Base) }
    let(:instance) { instance_double(described_class) }

    before do
      allow(described_class).to receive(:repo_identifiers).and_return(%w[ghost boo])
      allow(described_class).to receive(:new).and_return(instance)
    end

    context 'when no CLI args are given' do
      let(:args) { [] }

      it 'creates a new instance with the repo identifiers' do
        expect(described_class.from_git(git, args)).to eq instance
      end
    end

    context 'when CLI args are given' do
      let(:args) { ['foo'] }

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

    context "when CLI arg isn't in the right format" do
      let(:args) { ['foo'] }

      it 'raises a PluginUsageError' do
        expect { described_class.from_args(args) }.to raise_error(Repofetch::PluginUsageError)
      end
    end

    context 'when CLI args are given' do
      let(:args) { ['ghost/boo'] }

      it 'creates a new instance with the repo identifiers' do
        expect(described_class.from_args(args)).to eq instance
      end
    end
  end
end
