require 'spec_helper'
require 'ablab/store/store_examples'

describe Ablab::Store::Memory do
  let(:store) { Ablab::Store::Memory.new }
  include_examples 'store', Ablab::Store::Memory.new
end
