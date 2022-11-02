# frozen_string_literal: true

require 'repofetch'

RSpec.describe Repofetch do
  describe '#register_plugin' do
    after { described_class.send(:clear_plugins) }

    context 'with empty mock_plugin' do
      let(:mock_plugin) { Class.new(described_class::Plugin) }

      it 'adds a plugin to the list of plugins' do
        expect(described_class.register_plugin(mock_plugin)).to eq [mock_plugin]
      end
    end
  end

  describe '#replace_or_register_plugin' do
    let(:old_plugin) { Class.new(described_class::Plugin) }
    let(:new_plugin) { Class.new(described_class::Plugin) }

    context 'when there is no old plugin to replace' do
      after { described_class.send(:clear_plugins) }

      it 'adds a plugin to the list of plugins' do
        expect(described_class.replace_or_register_plugin(old_plugin, new_plugin)).to eq [new_plugin]
      end
    end

    context 'when there is an old plugin to replace' do
      before { described_class.register_plugin(old_plugin) }
      after { described_class.send(:clear_plugins) }

      it 'replaces the old plugin' do
        expect(described_class.replace_or_register_plugin(old_plugin, new_plugin)).to eq [new_plugin]
      end

      it 'does not contain the old plugin' do
        expect(described_class.replace_or_register_plugin(old_plugin, new_plugin)).not_to include(old_plugin)
      end
    end
  end

  describe Repofetch::Plugin, '#register' do
    after { Repofetch.send(:clear_plugins) }

    context 'with empty mock_plugin' do
      let(:mock_plugin) { Class.new(described_class) }

      it 'adds a plugin to the list of plugins' do
        expect(mock_plugin.register).to eq [mock_plugin]
      end
    end
  end

  describe Repofetch::Plugin, '#replace_or_register' do
    after { Repofetch.send(:clear_plugins) }

    let(:old_plugin) { Class.new(described_class) }
    let(:new_plugin) { Class.new(described_class) }

    context 'when there is no old plugin to replace' do
      it 'adds a plugin to the list of plugins' do
        expect(new_plugin.replace_or_register(old_plugin)).to eq [new_plugin]
      end
    end

    context 'when there is an old plugin to replace' do
      before { Repofetch.register_plugin(old_plugin) }

      it 'replaces the old plugin' do
        expect(new_plugin.replace_or_register(old_plugin)).to eq [new_plugin]
      end

      it 'does not contain the old plugin' do
        expect(new_plugin.replace_or_register(old_plugin)).not_to include(old_plugin)
      end
    end
  end
end
