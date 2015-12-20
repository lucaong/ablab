require 'spec_helper'

RSpec.shared_examples 'store' do |store_instance|
  let(:store) { store_instance }

  describe '#track_view!' do
    it 'tracks views' do
      5.times { store.track_view!(:foo, :a) }
      7.times { store.track_view!(:foo, :b) }
      3.times { store.track_view!(:bar, :b) }
      expect(store.views(:foo, :a)).to eq(5)
      expect(store.views(:foo, :b)).to eq(7)
      expect(store.views(:bar, :b)).to eq(3)
    end
  end

  describe '#track_conversion!' do
    it 'tracks conversions' do
      5.times { store.track_conversion!(:foo, :a) }
      7.times { store.track_conversion!(:foo, :b) }
      3.times { store.track_conversion!(:bar, :b) }
      expect(store.conversions(:foo, :a)).to eq(5)
      expect(store.conversions(:foo, :b)).to eq(7)
      expect(store.conversions(:bar, :b)).to eq(3)
    end
  end

  describe '#views' do
    it 'returns 0 if nothing was tracked' do
      expect(store.views(:xxx, :a)).to eq(0)
    end
  end

  describe '#conversions' do
    it 'returns 0 if nothing was tracked' do
      expect(store.conversions(:xxx, :a)).to eq(0)
    end
  end
end
