# frozen_string_literal: true

require 'repofetch'

RSpec.describe Repofetch::Plugin do
  describe '#to_s' do
    let(:mock_plugin) do
      Class.new described_class do
        def initialize(stats)
          super
          @stats.concat(stats)
        end

        def header
          'plugin header'
        end

        def ascii
          <<~ASCII
            1234567890
            ABCDEFGHIJ
            !@#$^&*()_
            QWERTYUIOP
          ASCII
        end
      end
    end

    context 'when there are less data lines than ASCII lines' do
      let(:stats) { [] }

      it 'writes all lines aligned' do
        expect(mock_plugin.new(stats).to_s).to match_snapshot('plugin_to_s_more_ascii_lines')
      end
    end

    context 'when there are more data lines than ASCII lines' do
      let(:stats) do
        [
          Repofetch::Stat.new('field 1', 'OK'),
          Repofetch::Stat.new('field 2', 'Yes'),
          Repofetch::Stat.new('field 3', 'Sure!')
        ]
      end

      it 'writes all lines aligned' do
        out = mock_plugin.new(stats).to_s
        expect(out).to match_snapshot('plugin_to_s_less_ascii_lines')
      end
    end
  end
end
