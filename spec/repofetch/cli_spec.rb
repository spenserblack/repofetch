# frozen_string_literal: true

require 'git'
require 'repofetch'
require 'repofetch/cli'
require 'repofetch/config'
require 'repofetch/exceptions'
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

        def self.matches_repo?(*)
          true
        end

        def self.from_git(*)
          raise Repofetch::PluginUsageError, 'mock error from +from_git+'
        end

        def self.from_args(*)
          new
        end

        def ascii
          <<~ASCII
            HELLO WORLD
             I'M ASCII
          ASCII
        end

        def header
          'mock header'
        end

        def stats
          %w[foo bar]
        end
      end
    end

    before do
      Repofetch.send(:clear_plugins)
      plugin.register
    end

    # rubocop:disable RSpec/ExpectOutput
    # NOTE: For snapshot tests
    describe '#start' do
      let(:original_stdout) { $stdout }

      before { $stdout = StringIO.new }
      after { $stdout = original_stdout }

      it 'writes the plugin when the user explicitly picks it' do
        described_class.new(config, %w[--plugin Namespace::Myplugin]).start

        expect($stdout.string).to match_snapshot('cli_stdout_snapshot_1')
      end

      it 'does not call Git.open when the user has picked a plugin' do
        allow(Git).to receive(:open).and_raise('should not be called')
        described_class.new(config, %w[--plugin Namespace::Myplugin]).start

        expect(Git).not_to have_received(:open)
      end

      it 'outputs an error when the plugin is not used properly' do
        allow(Git).to receive(:open)

        expect { described_class.new(config, %w[-r .]).start }.to output("mock error from +from_git+\n").to_stderr
      end
    end
    # rubocop:enable RSpec/ExpectOutput

    describe '#define_options' do
      it 'sets the plugin when --plugin is used' do
        args = %w[--plugin Namespace::Myplugin]
        cli = described_class.new(config, args)
        cli.define_options.parse!(args)

        expect(cli.plugin).to eq(plugin)
      end

      it 'accepts the shortcut option for picking a plugin' do
        args = %w[--namespace-myplugin]
        cli = described_class.new(config, args)
        cli.define_options.parse!(args)

        expect(cli.plugin).to eq(plugin)
      end

      it 'sets the repository path when -r/--repository is used' do
        args = %w[--repository /path/to/repo]
        cli = described_class.new(config, args)
        cli.define_options.parse!(args)

        expect(cli.repository_path).to eq('/path/to/repo')
      end
    end
  end

  describe '#define_options' do
    let(:config) { Repofetch::Config.new }

    before { allow(Kernel).to receive(:exit) }

    context 'when -v/--version is passed' do
      let(:args) { %w[--version] }

      it 'prints the version' do
        expect do
          described_class.new(config, args).define_options.parse!(args)
        end.to output("repofetch #{Repofetch::VERSION}\n").to_stdout
      end
    end
  end
end
