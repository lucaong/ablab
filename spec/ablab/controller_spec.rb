require 'spec_helper'
require 'ostruct'

describe ABLab::Controller do
  let(:controller) do
    Class.new do
      include ABLab::Controller

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
