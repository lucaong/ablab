require 'spec_helper'
require 'ablab/store/store_examples'

describe ABLab::Store::Memory do
  include_examples 'store', ABLab::Store::Memory.new
end
