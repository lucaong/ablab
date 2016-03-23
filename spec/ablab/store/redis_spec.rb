require 'spec_helper'
require 'ablab/store/store_examples'

describe Ablab::Store::Redis do
  def cleanup
    redis = ::Redis.new(db: 2)
    keys  = redis.keys('ablabtest:*')
    redis.pipelined do
      keys.each { |key| redis.del(key) }
    end
  end

  around do |example|
    begin
      cleanup
      example.run
    ensure
      cleanup
    end
  end

  let(:store) { Ablab::Store::Redis.new(db: 2, key_prefix: 'ablabtest') }
  include_examples 'store'

  describe 'spool_set!' do
    it 'does not change the count' do
      5.times do |i|
        store.track_view!('foo', 'bar', i)
      end
      later = Time.at(Time.now.to_i + 60 * 60)
      allow(Time).to receive(:now).and_return(later)
      expect { store.send(:spool_set!, 'foo', 'bar', :sessions) }
        .not_to change { store.sessions('foo', 'bar') }
    end
  end
end

