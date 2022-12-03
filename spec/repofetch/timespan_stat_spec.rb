# frozen_string_literal: true

require 'repofetch'

RSpec.describe Repofetch::TimespanStat do
  describe '#format_value' do
    context 'when value is 2022/10/31 and now is 2022/12/31' do
      let(:value) { Time.new(2022, 10, 31) }
      let(:now) { Time.new(2022, 12, 31) }

      it 'returns "2 months ago"' do
        stat = described_class.new('foo', value)
        expect(stat.format_value(now)).to eq '2 months ago'
      end
    end

    context 'when value is 2022/10/31 and now is 2022/11/01' do
      let(:value) { Time.new(2022, 10, 31) }
      let(:now) { Time.new(2022, 11, 1) }

      it 'returns "1 day ago"' do
        stat = described_class.new('foo', value)
        expect(stat.format_value(now)).to eq '1 day ago'
      end
    end
  end
end
