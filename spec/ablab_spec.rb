require 'spec_helper'

describe Ablab do
  let(:ab) do
    Module.new { extend Ablab::ModuleMethods }
  end

  it 'has a version number' do
    expect(Ablab::VERSION).not_to be nil
  end

  describe '.experiment' do
    it 'creates an experiment' do
      ab.experiment :foo_bar do; end
      expect(ab.experiments[:foo_bar]).to be_a(Ablab::Experiment)
    end
  end

  describe '.tracker' do
    around do |example|
      begin
        Ablab::Store::Dummy = Class.new
        example.run
      ensure
        Ablab::Store.send(:remove_const, :Dummy)
      end
    end

    it 'returns a Ablab::Store::Memory instance if store was never set' do
      expect(ab.tracker).to be_a(Ablab::Store::Memory)
    end

    it 'returns the store if it was set' do
      ab.store :dummy
      expect(ab.tracker).to be_a(Ablab::Store::Dummy)
    end
  end

  describe '.dashboard_credentials' do
    it 'raises if called without name or password' do
      expect {
        ab.dashboard_credentials(name: 'foo')
      }.to raise_error(Ablab::InvalidCredentials)

      expect {
        ab.dashboard_credentials(password: 'foo')
      }.to raise_error(Ablab::InvalidCredentials)
    end

    it 'sets and gets the credentials' do
      ab.dashboard_credentials(name: 'foo', password: 'bar')
      expect(ab.dashboard_credentials).to eq(name: 'foo', password: 'bar')
    end
  end

  describe Ablab::Experiment do
    let(:experiment) do
      Ablab::Experiment.new('foo') do; end
    end

    it 'automatically creates a control group' do
      expect(experiment.control).to be_a(Ablab::Group)
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

    describe '#description' do
      it 'sets the experiment goal' do
        experiment.goal 'foo bar'
        expect(experiment.goal).to eq('foo bar')
      end
    end

    describe '#group' do
      it 'creates a group' do
        experiment.group :a, description: 'foo bar baz'
        expect(experiment.groups.last).to be_a(Ablab::Group)
        expect(experiment.groups.last.description).to eq('foo bar baz')
      end

      it 'symbolizes the group name' do
        experiment.group 'yeah'
        expect(experiment.groups.last.name).to eq(:yeah)
      end
    end

    describe '.results' do
      it 'returns the results of the experiment' do
        experiment.group :x, description: 'a test group'
        allow(Ablab.tracker).to receive(:views) do |_, group|
          { control: 201, x: 238 }[group]
        end
        allow(Ablab.tracker).to receive(:sessions) do |_, group|
          { control: 182, x: 188 }[group]
        end
        allow(Ablab.tracker).to receive(:successes) do |_, group|
          { control: 38, x: 70 }[group]
        end
        allow(Ablab.tracker).to receive(:conversions) do |_, group|
          { control: 35, x: 61 }[group]
        end
        results = experiment.results
        expect(results[:control]).to eq({
          views:       201,
          sessions:    182,
          successes:   38,
          conversions: 35,
          control:     true,
          description: 'control group'
        })
        expect(results[:x]).to eq({
          views:       238,
          sessions:    188,
          successes:   70,
          conversions: 61,
          control:     false,
          z_score:     2.9410157224928595,
          description: 'a test group'
        })
      end
    end
  end

  describe Ablab::Run do
    let(:experiment) do
      Ablab::Experiment.new(:foo) do
        group :a
        group :b
      end
    end

    it 'gets assigned to the right group' do
      run = Ablab::Run.new(experiment, 0)
      allow(run).to receive(:draw).and_return 0
      expect(run).to be_in_group(:control)
      run = Ablab::Run.new(experiment, 0)
      allow(run).to receive(:draw).and_return 334
      expect(run).to be_in_group(:a)
      run = Ablab::Run.new(experiment, 0)
      allow(run).to receive(:draw).and_return 999
      expect(run).to be_in_group(:b)
    end

    it 'assigns the same session ID to the same group' do
      run1 = Ablab::Run.new(experiment, 'foobar')
      run2 = Ablab::Run.new(experiment, 'foobar')
      expect(run1.group).to eq(run2.group)
    end
  end
end
