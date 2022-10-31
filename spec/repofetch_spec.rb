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

  describe Repofetch::Plugin, '#register' do
    after { Repofetch.send(:clear_plugins) }

    context 'with empty mock_plugin' do
      let(:mock_plugin) { Class.new(described_class) }

      it 'adds a plugin to the list of plugins' do
        expect(mock_plugin.register).to eq [mock_plugin]
      end
    end
  end
end
