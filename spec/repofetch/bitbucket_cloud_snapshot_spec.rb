# frozen_string_literal: true

require 'repofetch/bitbucketcloud'
require 'sawyer'

describe Repofetch::BitbucketCloud do
  describe '#to_s' do
    let(:agent) { instance_double(Sawyer::Agent) }
    let(:instance) { described_class.new('foo/bar') }

    before do
      # TODO: Instead of making time relative to test, the raw time should be used.
      last_year = Time.new(Time.now.year - 1, Time.now.month, Time.now.day)
      clone_links = [
        { 'name' => 'https', 'href' => 'https://bitbucket.org/foo/bar.git' },
        { 'name' => 'ssh', 'href' => 'git@bitbucket.org/foo/bar.git' }
      ]
      repositories_response = instance_double(Sawyer::Response, data: {
                                                'links' => { 'clone' => clone_links },
                                                'created_on' => last_year,
                                                'updated_on' => last_year,
                                                'size' => 1000,
                                                'owner' => { 'display_name' => 'Foo' },
                                                'name' => 'Bar'
                                              })
      watchers_response = instance_double(Sawyer::Response, data: { 'size' => 10 })
      forks_response = instance_double(Sawyer::Response, data: { 'size' => 3 })
      issues_response = instance_double(Sawyer::Response, data: { 'size' => 100 })
      pr_response = instance_double(Sawyer::Response, data: { 'size' => 75 })
      allow(Sawyer::Agent).to receive(:new).and_return(agent)
      allow(agent).to receive(:call).with(:get, 'repositories/foo/bar').and_return(repositories_response)
      allow(agent).to receive(:call).with(:get, 'repositories/foo/bar/watchers').and_return(watchers_response)
      allow(agent).to receive(:call).with(:get, 'repositories/foo/bar/forks').and_return(forks_response)
      allow(agent).to receive(:call).with(:get, 'repositories/foo/bar/issues').and_return(issues_response)
      allow(agent).to receive(:call).with(:get, 'repositories/foo/bar/pullrequests').and_return(pr_response)
    end

    it 'renders the stats and ASCII art' do
      expect(described_class.new('foo/bar').to_s).to match_snapshot('repofetch_bitbucketcloud_1')
    end
  end
end
