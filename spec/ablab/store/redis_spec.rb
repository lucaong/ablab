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
end

