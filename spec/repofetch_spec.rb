# frozen_string_literal: true

require 'git'
require 'repofetch'

RSpec.describe Repofetch do
  describe '#register_plugin' do
    after { described_class.send(:clear_plugins) }

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
      after { described_class.send(:clear_plugins) }

      it 'adds a plugin to the list of plugins' do
        described_class.replace_or_register_plugin(old_plugin, new_plugin)
        expect(described_class.plugins).to eq [new_plugin]
      end
    end

    context 'when there is an old plugin to replace' do
      before { described_class.register_plugin(old_plugin) }
      after { described_class.send(:clear_plugins) }

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

  describe Repofetch::Plugin, '#register' do
    after { Repofetch.send(:clear_plugins) }

    context 'with empty mock_plugin' do
      let(:mock_plugin) { Class.new(described_class) }

      it 'adds a plugin to the list of plugins' do
        mock_plugin.register
        expect(Repofetch.plugins).to eq [mock_plugin]
      end
    end
  end

  describe Repofetch::Plugin, '#replace_or_register' do
    after { Repofetch.send(:clear_plugins) }

    let(:old_plugin) { Class.new(described_class) }
    let(:new_plugin) { Class.new(described_class) }

    context 'when there is no old plugin to replace' do
      it 'adds a plugin to the list of plugins' do
        new_plugin.replace_or_register(old_plugin)
        expect(Repofetch.plugins).to eq [new_plugin]
      end
    end

    context 'when there is an old plugin to replace' do
      before { Repofetch.register_plugin(old_plugin) }

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

  describe Repofetch::Plugin, '#lines_with_ascii' do
    let(:mock_plugin) do
      Class.new described_class do
        def ascii
          <<~ASCII
            1234567890
            ABCDEFGHIJ
          ASCII
        end
      end
    end

    context 'when there are less data lines than ASCII lines' do
      it 'writes all lines aligned' do
        expected = <<~EXPECTED
          1234567890                                   field 1: OK
          ABCDEFGHIJ
        EXPECTED
        expect(mock_plugin.new.lines_with_ascii(['field 1: OK'])).to eq expected
      end
    end

    context 'when there are more data lines than ASCII lines' do
      let(:expected) do
        <<~EXPECTED
          1234567890                                   field 1: OK
          ABCDEFGHIJ                                   field 2: Yes
                                                       field 3: Sure!
        EXPECTED
      end

      it 'writes all lines aligned' do
        expect(mock_plugin.new.lines_with_ascii(['field 1: OK', 'field 2: Yes', 'field 3: Sure!'])).to eq expected
      end
    end
  end
end
