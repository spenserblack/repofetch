# frozen_string_literal: true

require 'git'
require 'repofetch/util'

describe Repofetch::Util do
  subject(:dummy) { Class.new { include Repofetch::Util }.new }

  describe '#default_remote' do
    let(:git) { instance_double(Git::Base) }
    let(:origin) { instance_double(Git::Remote, name: 'origin') }
    let(:upstream) { instance_double(Git::Remote, name: 'upstream') }

    context 'when git has a remote named origin' do
      before { allow(git).to receive(:remotes).and_return([upstream, origin]) }

      it 'always returns the remote named "origin"' do
        expect(dummy.default_remote(git)).to eq origin
      end
    end

    context 'when git has no remote named origin' do
      before { allow(git).to receive(:remotes).and_return([upstream]) }

      it 'returns the first remote' do
        expect(dummy.default_remote(git)).to eq upstream
      end
    end
  end

  describe '#default_remote_url' do
    let(:git) { instance_double(Git::Base) }
    let(:url) { 'https://github.com/ghost/boo.git' }
    let(:remote) { instance_double(Git::Remote, url: url, name: 'origin') }

    before do
      allow(git).to receive(:remotes).and_return([remote])
      allow(remote).to receive(:url).and_return(url)
    end

    it 'returns the url of the default remote' do
      expect(dummy.default_remote_url(git)).to eq url
    end
  end
end
