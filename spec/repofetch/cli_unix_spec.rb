# frozen_string_literal: true

require 'git'
require 'repofetch'
require 'repofetch/cli'
require 'repofetch/config'
require 'stringio'

RSpec.describe Repofetch::CLI do
  before { allow(Dir).to receive(:home).and_return('/home/me') }

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
        cli = described_class.new(config, [])

        expect(cli.define_options.to_s).to match_snapshot('cli_unix_snapshot_1')
      end

      it 'sets the plugin when --plugin is used' do
        args = %w[--plugin Namespace::Myplugin]
        cli = described_class.new(config, args)
        cli.define_options.parse!(args)

        expect(cli.plugin).to eq(plugin)
      end
    end
  end
end
