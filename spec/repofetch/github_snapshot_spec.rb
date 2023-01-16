# frozen_string_literal: true

require 'octokit'
require 'repofetch/github'

describe Repofetch::Github do
  describe '#stats' do
    let(:client) { instance_double(Octokit::Client) }

    before do
      allow(Octokit::Client).to receive(:new).and_return(client)
      allow(client).to receive(:repository).with('ghost/boo').and_return({
                                                                           'clone_url' => 'https://github.com/ghost/boo.git',
                                                                           'ssh_url' => 'git@github.com:ghost/boo.git',
                                                                           'stargazers_count' => 1,
                                                                           'subscribers_count' => 2,
                                                                           'forks_count' => 3,
                                                                           'created_at' => Time.new(2023, 1, 16),
                                                                           'updated_at' => Time.new(2023, 1, 17),
                                                                           'size' => 1000
                                                                         })
      allow(client).to receive(:search_issues)
        .with('repo:ghost/boo is:issue', page: 0, per_page: 1).and_return({ 'total_count' => 10 })
      allow(client).to receive(:search_issues)
        .with('repo:ghost/boo is:pr', page: 0, per_page: 1).and_return({ 'total_count' => 20 })
    end

    it 'renders the stats and ASCII art' do
      expect(described_class.new('ghost', 'boo').to_s).to match_snapshot('repofetch_github_1')
    end
  end
end
