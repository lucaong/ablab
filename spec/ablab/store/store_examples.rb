require 'spec_helper'

RSpec.shared_examples 'store' do
  describe '#track_view!' do
    it 'tracks views' do
      5.times { store.track_view!(:foo, :a, 'abc') }
      7.times { store.track_view!(:foo, :b, 'abc') }
      3.times { store.track_view!(:bar, :b, 'abc') }
      expect(store.views(:foo, :a)).to eq(5)
      expect(store.views(:foo, :b)).to eq(7)
      expect(store.views(:bar, :b)).to eq(3)
    end

    it 'tracks unique sessions' do
      2.times { store.track_view!(:foo, :a, 'foo') }
      3.times { store.track_view!(:foo, :a, 'bar') }
      3.times { store.track_view!(:foo, :b, 'foo') }
      3.times { store.track_view!(:bar, :b, 'bar') }
      expect(store.sessions(:foo, :a)).to eq(2)
      expect(store.sessions(:foo, :b)).to eq(1)
      expect(store.sessions(:bar, :b)).to eq(1)
    end
  end

  describe '#track_success!' do
    it 'tracks successes' do
      5.times { store.track_success!(:foo, :a, 'abc') }
      7.times { store.track_success!(:foo, :b, 'abc') }
      3.times { store.track_success!(:bar, :b, 'abc') }
      expect(store.successes(:foo, :a)).to eq(5)
      expect(store.successes(:foo, :b)).to eq(7)
      expect(store.successes(:bar, :b)).to eq(3)
    end

    it 'tracks unique conversions' do
      5.times { |i| store.track_success!(:foo, :a, i) }
      2.times { store.track_success!(:foo, :b, 'foo') }
      3.times { store.track_success!(:foo, :b, 'bar') }
      3.times { store.track_success!(:bar, :b, 'foo') }
      expect(store.conversions(:foo, :a)).to eq(5)
      expect(store.conversions(:foo, :b)).to eq(2)
      expect(store.conversions(:bar, :b)).to eq(1)
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

  describe '#sessions' do
    it 'returns 0 if nothing was tracked' do
      expect(store.sessions(:xxx, :a)).to eq(0)
    end
  end

  describe '#counts' do
    it 'returns all counts in one call' do
      2.times { store.track_view!(:foo, :a, 'foo') }
      3.times { store.track_view!(:foo, :a, 'bar') }
      1.times { store.track_success!(:foo, :a, 'foo') }
      5.times { store.track_success!(:foo, :a, 'bar') }
      2.times { store.track_success!(:foo, :a, 'baz') }
      expect(store.counts(:foo, :a)).to eq(views: 5, sessions: 2, successes: 8, conversions: 3)
    end
  end
end
