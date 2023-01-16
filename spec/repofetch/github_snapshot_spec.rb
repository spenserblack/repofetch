# frozen_string_literal: true

require 'octokit'
require 'repofetch/github'

describe Repofetch::Github do
  describe '#stats' do
    let(:client) { instance_double(Octokit::Client) }

    # TODO: Instead of making time relative to test, the raw time should be used.
    last_year = Time.new(Time.now.year - 1, Time.now.month, Time.now.day)
    before do
      allow(Octokit::Client).to receive(:new).and_return(client)
      allow(client).to receive(:repository).with('ghost/boo').and_return({
                                                                           'clone_url' => 'https://github.com/ghost/boo.git',
                                                                           'ssh_url' => 'git@github.com:ghost/boo.git',
                                                                           'stargazers_count' => 1,
                                                                           'subscribers_count' => 2,
                                                                           'forks_count' => 3,
                                                                           'created_at' => last_year,
                                                                           'updated_at' => last_year,
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
