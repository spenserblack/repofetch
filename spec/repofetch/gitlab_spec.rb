# frozen_string_literal: true

require 'repofetch/gitlab'

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
end
