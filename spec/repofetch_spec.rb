# frozen_string_literal: true

require 'git'
require 'repofetch'

RSpec.describe Repofetch do
  describe '#register_plugin' do
    before { described_class.send(:clear_plugins) }

    context 'with empty mock_plugin' do
      let(:mock_plugin) { Class.new(described_class::Plugin) }

      it 'adds a plugin to the list of plugins' do
        described_class.register_plugin(mock_plugin)
        expect(described_class.plugins).to eq [mock_plugin]
      end
    end
  end

  describe '#replace_or_register_plugin' do
    let(:old_plugin) { Class.new(described_class::Plugin) }
    let(:new_plugin) { Class.new(described_class::Plugin) }

    context 'when there is no old plugin to replace' do
      before { described_class.send(:clear_plugins) }

      it 'adds a plugin to the list of plugins' do
        described_class.replace_or_register_plugin(old_plugin, new_plugin)
        expect(described_class.plugins).to eq [new_plugin]
      end
    end

    context 'when there is an old plugin to replace' do
      before do
        described_class.send(:clear_plugins)
        described_class.register_plugin(old_plugin)
      end

      it 'replaces the old plugin' do
        described_class.replace_or_register_plugin(old_plugin, new_plugin)
        expect(described_class.plugins).to eq [new_plugin]
      end

      it 'does not contain the old plugin' do
        described_class.replace_or_register_plugin(old_plugin, new_plugin)
        expect(described_class.plugins).not_to include(old_plugin)
      end
    end
  end

  describe '#get_plugin' do
    before { described_class.send(:clear_plugins) }

    context 'when no plugins match the repo' do
      it 'raises a NoPluginsError' do
        expect { described_class.get_plugin(nil, nil, nil) }.to raise_error(described_class::NoPluginsError)
      end
    end

    context 'when multiple plugins match the repo' do
      before do
        2.times do
          Class.new(described_class::Plugin) do
            def self.matches_repo?(*)
              true
            end
          end.register
        end
      end

      it 'raises a TooManyPluginsError' do
        expect { described_class.get_plugin(nil, nil, nil) }.to raise_error(Repofetch::TooManyPluginsError)
      end
    end

    context 'when one plugin matches the repo' do
      let(:plugin) do
        Class.new(described_class::Plugin) do
          def self.matches_repo?(*)
            true
          end

          def self.from_git(*)
            new
          end
        end
      end

      before { plugin.register }

      it 'returns an instance of that plugin' do
        expect(described_class.get_plugin(nil, nil, nil).class).to be plugin
      end
    end

    context 'when a plugin author forgets to implement #matches_repo?' do
      let(:ok_plugin) do
        Class.new(described_class::Plugin) do
          def self.matches_repo?(*)
            true
          end

          def self.from_git(*)
            new
          end
        end
      end

      let(:bad_plugin) do
        Class.new(described_class::Plugin)
      end

      before { [ok_plugin, bad_plugin].each(&:register) }

      it 'generates a warning' do
        expect do
          described_class.get_plugin(nil, nil, nil)
        end.to output(/Does not implement \+matches_repo\?\+/).to_stderr
      end
    end
  end

  describe Repofetch::Plugin, '#register' do
    before { Repofetch.send(:clear_plugins) }

    context 'with empty mock_plugin' do
      let(:mock_plugin) { Class.new(described_class) }

      it 'adds a plugin to the list of plugins' do
        mock_plugin.register
        expect(Repofetch.plugins).to eq [mock_plugin]
      end
    end
  end

  describe Repofetch::Plugin, '#replace_or_register' do
    before { Repofetch.send(:clear_plugins) }

    let(:old_plugin) { Class.new(described_class) }
    let(:new_plugin) { Class.new(described_class) }

    context 'when there is no old plugin to replace' do
      it 'adds a plugin to the list of plugins' do
        new_plugin.replace_or_register(old_plugin)
        expect(Repofetch.plugins).to eq [new_plugin]
      end
    end

    context 'when there is an old plugin to replace' do
      before do
        Repofetch.send(:clear_plugins)
        Repofetch.register_plugin(old_plugin)
      end

      it 'replaces the old plugin' do
        new_plugin.replace_or_register(old_plugin)
        expect(Repofetch.plugins).to eq [new_plugin]
      end

      it 'does not contain the old plugin' do
        new_plugin.replace_or_register(old_plugin)
        expect(Repofetch.plugins).not_to include(old_plugin)
      end
    end
  end

  describe Repofetch::Plugin, '#ascii' do
    context 'when a plugin subclass does not override the ascii method' do
      let(:mock_plugin) { Class.new(described_class) }

      it 'raises NoMethodError' do
        expect { mock_plugin.new('foo').ascii }.to raise_error(NoMethodError)
      end
    end
  end

  describe Repofetch::Plugin, '#matches_repo?' do
    context 'when a plugin subclass does not override the matches_repo? method' do
      let(:mock_plugin) { Class.new(described_class) }

      it 'raises NoMethodError' do
        expect { mock_plugin.matches_repo?(Git::Base.new) }.to raise_error(NoMethodError)
      end
    end
  end
end
