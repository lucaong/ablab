require 'spec_helper'
require 'ostruct'

describe ABLab::Helper do
  let(:controller) do
    Class.new do
      include ABLab::Helper

      def env
        { 'rack.session' => OpenStruct.new(id: 'abc123') }
      end
    end.new
  end

  before do
    ABLab.setup do
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
    expect(klass).to receive(:helper_method).with :session_id_for_experiments
    klass.send(:include, ABLab::Helper)
  end

  describe '#experiment' do
    it 'returns a Run for the given experiment name' do
      run = controller.send(:experiment, :xxx)
      expect(run).to be_a(ABLab::Run)
      expect(run.experiment).to be(ABLab.experiments[:xxx])
    end

    it 'returns the same Run if called twice with the same name' do
      run  = controller.send(:experiment, :xxx)
      run2 = controller.send(:experiment, :xxx)
      expect(run).to be(run2)
    end
  end
end
