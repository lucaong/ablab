require 'spec_helper'
require 'ablab/store/store_examples'

describe ABLab::Store::Redis do
  around do |example|
    begin
      example.run
    ensure
      redis = ::Redis.new
      keys  = redis.keys('ablab:*')
      redis.pipelined do
        keys.each { |key| redis.del(key) }
      end
    end
  end

  include_examples 'store', ABLab::Store::Redis.new
end

