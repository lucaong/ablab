require 'spec_helper'
require 'ablab/store/store_examples'

describe ABLab::Store::Memory do
  let(:store) { ABLab::Store::Memory.new }
  include_examples 'store', ABLab::Store::Memory.new
end
