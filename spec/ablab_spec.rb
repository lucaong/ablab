require 'spec_helper'

describe ABLab do
  let(:ab) do
    Module.new { extend ABLab::ModuleMethods }
  end

  it 'has a version number' do
    expect(ABLab::VERSION).not_to be nil
  end

  describe '.experiment' do
    it 'creates an experiment' do
      ab.experiment :foo_bar do; end
      expect(ab.experiments[:foo_bar]).to be_a(ABLab::Experiment)
    end
  end

  describe '.tracker' do
    around do |example|
      begin
        ABLab::Store::Dummy = Class.new
        example.run
      ensure
        ABLab::Store.send(:remove_const, :Dummy)
      end
    end

    it 'returns a ABLab::Store::Memory instance if store was never set' do
      expect(ab.tracker).to be_a(ABLab::Store::Memory)
    end

    it 'returns the store if it was set' do
      ab.store :dummy
      expect(ab.tracker).to be_a(ABLab::Store::Dummy)
    end
  end

  describe ABLab::Experiment do
    let(:experiment) do
      ABLab::Experiment.new('foo') do; end
    end

    it 'automatically creates a control group' do
      expect(experiment.control).to be_a(ABLab::Group)
      expect(experiment.groups).to_not be_empty
    end

    it 'symbolizes its name' do
      expect(experiment.name).to eq(:foo)
    end

    describe '#description' do
      it 'sets the description' do
        experiment.description 'foo bar'
        expect(experiment.description).to eq('foo bar')
      end
    end

    describe '#group' do
      it 'creates a group' do
        experiment.group :a, description: 'foo bar baz'
        expect(experiment.groups.last).to be_a(ABLab::Group)
        expect(experiment.groups.last.description).to eq('foo bar baz')
      end

      it 'symbolizes the group name' do
        experiment.group 'yeah'
        expect(experiment.groups.last.name).to eq(:yeah)
      end
    end

    describe '.results' do
      it 'returns the results of the experiment' do
        experiment.group :x
        allow(ABLab.tracker).to receive(:views) do |_, group|
          { control: 201, x: 238 }[group]
        end
        allow(ABLab.tracker).to receive(:sessions) do |_, group|
          { control: 182, x: 188 }[group]
        end
        allow(ABLab.tracker).to receive(:successes) do |_, group|
          { control: 38, x: 70 }[group]
        end
        allow(ABLab.tracker).to receive(:conversions) do |_, group|
          { control: 35, x: 61 }[group]
        end
        results = experiment.results
        expect(results.first).to eq({
          views:       201,
          sessions:    182,
          successes:   38,
          conversions: 35,
          control:     true
        })
        expect(results.last).to eq({
          views:       238,
          sessions:    188,
          successes:   70,
          conversions: 61,
          control:     false,
          z_score:     2.9410157224928595
        })
      end
    end
  end

  describe ABLab::Run do
    let(:experiment) do
      ABLab::Experiment.new(:foo) do
        group :a
        group :b
      end
    end

    it 'gets assigned to the right group' do
      run = ABLab::Run.new(experiment, 0)
      allow(run).to receive(:draw).and_return 0
      expect(run).to be_in_group(:control)
      run = ABLab::Run.new(experiment, 0)
      allow(run).to receive(:draw).and_return 334
      expect(run).to be_in_group(:a)
      run = ABLab::Run.new(experiment, 0)
      allow(run).to receive(:draw).and_return 999
      expect(run).to be_in_group(:b)
    end
  end
end
