# frozen_string_literal: true

require 'repofetch'

RSpec.describe Repofetch::Plugin do
  describe '#lines_with_ascii' do
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
        expect(mock_plugin.new.lines_with_ascii(['field 1: OK'])).to match_snapshot('lines_with_ascii_more_ascii_lines')
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
        with_ascii = mock_plugin.new.lines_with_ascii(['field 1: OK', 'field 2: Yes', 'field 3: Sure!'])
        expect(with_ascii).to match_snapshot('lines_with_ascii_less_ascii_lines')
      end
    end
  end
end
