require 'spec_helper'
require 'ostruct'

describe Ablab::Helper do
  let(:cookies) { Hash.new }

  let(:controller) do
    Class.new do
      include Ablab::Helper

      def env
        { 'rack.session' => OpenStruct.new(id: 'abc123') }
      end
    end.new
  end

  before do
    Ablab.setup do
      experiment :xxx do
        group :a
        group :b
      end
    end
  end

  it 'calls helper_method if the including class implements it' do
    klass = Class.new do
      def self.helper_method(_); end
    end
    expect(klass).to receive(:helper_method).with :experiment
    expect(klass).to receive(:helper_method).with :ablab_session_id
    klass.send(:include, Ablab::Helper)
  end

  describe '#experiment' do
    it 'returns a Run for the given experiment name' do
      allow(controller).to receive(:cookies).and_return(cookies)
      run = controller.send(:experiment, :xxx)
      expect(run).to be_a(Ablab::Run)
      expect(run.experiment).to be(Ablab.experiments[:xxx])
    end

    it 'returns the same Run if called twice with the same name' do
      allow(controller).to receive(:cookies).and_return(cookies)
      run  = controller.send(:experiment, :xxx)
      run2 = controller.send(:experiment, :xxx)
      expect(run).to be(run2)
    end
  end
end
