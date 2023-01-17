# frozen_string_literal: true

require 'repofetch/gitlab'
require 'sawyer'

describe Repofetch::Gitlab do
  describe '#to_s' do
    let(:agent) { instance_double(Sawyer::Agent) }
    let(:instance) { described_class.new('123') }

    before do
      # TODO: Instead of making time relative to test, the raw time should be used.
      last_year = Time.new(Time.now.year - 1, Time.now.month, Time.now.day)
      response = instance_double(Sawyer::Response)
      allow(Sawyer::Agent).to receive(:new).and_return(agent)
      allow(agent).to receive(:call).with(:get, 'projects/123').and_return(response)
      allow(response).to receive(:data).and_return({
                                                     'name_with_namespace' => 'Foo / Bar',
                                                     'http_url_to_repo' => 'https://gitlab.com/foo/bar.git',
                                                     'ssh_url_to_repo' => 'git@gitlab.com:foo/bar.git',
                                                     'star_count' => 1,
                                                     'forks_count' => 2,
                                                     'created_at' => last_year,
                                                     'last_activity_at' => last_year,
                                                     'open_issues_count' => 3
                                                   })
    end

    context 'when token is nil' do
      before { allow(instance).to receive(:token).and_return(nil) }

      it 'renders the stats and ASCII art' do
        expect(instance.to_s).to match_snapshot('repofetch_gitlab_1')
      end
    end

    context 'when token is not nil' do
      before { allow(instance).to receive(:token).and_return('abc123') }

      it 'includes open issues count' do
        expect(instance.to_s).to match_snapshot('repofetch_gitlab_2')
      end
    end
  end
end
