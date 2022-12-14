# frozen_string_literal: true

require 'repofetch'
require 'repofetch/cli'
require 'repofetch/config'

RSpec.describe Repofetch::CLI do
  context 'when +Namespace::Myplugin+ is a registered plugin' do
    let(:config) { Repofetch::Config.new }
    let(:plugin) do
      Class.new(Repofetch::Plugin) do
        def self.name
          'Namespace::Myplugin'
        end
      end
    end

    before do
      Repofetch.send(:clear_plugins)
      plugin.register
    end

    describe '#define_options' do
      it 'notes options and helpful tips in the help text' do
        Dir.stub(:home) { '/home/me' }
        cli = described_class.new(config, [])

        expect(cli.define_options.to_s).to match_snapshot('cli_snapshot_1')
      end
    end
  end
end
