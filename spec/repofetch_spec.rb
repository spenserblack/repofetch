# frozen_string_literal: true

require 'repofetch'

RSpec.describe Repofetch do
  describe '#add2' do
    it 'adds 2 and 3 and returns 5' do
      expect(described_class.add2(3)).to eq 5
    end
  end
end
