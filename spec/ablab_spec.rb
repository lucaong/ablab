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

  describe ".on_track" do
    it "adds a tracking callback" do
      block = Proc.new {}
      ab.on_track(&block)
      expect(ab.callbacks).to eq([block])
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

    describe '#goal' do
      it 'sets the experiment goal' do
        experiment.goal 'foo bar'
        expect(experiment.goal).to eq('foo bar')
      end
    end

    describe '#percentage_of_visitors' do
      it 'returns 100 if never set' do
        expect(experiment.percentage_of_visitors).to eq(100)
      end

      it 'sets the percentage of visitors included in the experiment' do
        experiment.percentage_of_visitors 25
        expect(experiment.percentage_of_visitors).to eq(25)
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

    let(:request) { double(:request) }

    let(:run) do
      Ablab::Run.new(experiment, '86wfd8w6df', request)
    end

    it 'gets assigned to the right group' do
      run = Ablab::Run.new(experiment, 'abc', request)
      allow(run).to receive(:draw).and_return 0
      expect(run).to be_in_group(:control)
      run = Ablab::Run.new(experiment, 'abc', request)
      allow(run).to receive(:draw).and_return 334
      expect(run).to be_in_group(:a)
      run = Ablab::Run.new(experiment, 'abc', request)
      allow(run).to receive(:draw).and_return 999
      expect(run).to be_in_group(:b)
    end

    it 'assigns the same session ID to the same group' do
      run1 = Ablab::Run.new(experiment, 'abc', request)
      run2 = Ablab::Run.new(experiment, 'abc', request)
      expect(run1.group).to eq(run2.group)
    end

    it 'selects only the given percentage of users' do
      experiment.percentage_of_visitors 30
      run = Ablab::Run.new(experiment, 'abc', request)
      allow(run).to receive(:draw).and_return 0
      expect(run).to be_in_group(:control)
      run = Ablab::Run.new(experiment, 'abc', request)
      allow(run).to receive(:draw).and_return 100
      expect(run).to be_in_group(:a)
      run = Ablab::Run.new(experiment, 'abc', request)
      allow(run).to receive(:draw).and_return 200
      expect(run).to be_in_group(:b)
      run = Ablab::Run.new(experiment, 'abc', request)
      allow(run).to receive(:draw).and_return 300
      expect(run.group).to be_nil
    end

    describe "#draw" do
      it "is stable across ruby processes" do
        d1 = Ablab::Run.new(experiment, '8asd7f8asf7', request).draw
        dir = File.expand_path(File.dirname(__FILE__), '../lib')
        d2 = `bundle exec ruby -I#{dir} -e "require 'ablab'; require 'ostruct'; puts Ablab::Run.new(OpenStruct.new(name: :foo), '8asd7f8asf7', nil).draw"`
        expect(d1).to eq(d2.to_i)
      end

      it "returns an integer number < 1000" do
        expect(
          (0..100).map { |i| Ablab::Run.new(experiment, "#{i}", request).draw }.all? { |x| x.is_a?(Integer) && x < 1000 }
        ).to be(true)
      end
    end

    describe "#group" do
      it "returns one of the groups" do
        expect(Ablab::Run.new(experiment, rand(12345).to_s, request).group).to be_in([:a, :b, :control])
      end

      it "returns the forced group, if set with the 'ablab_group' param" do
        params = { ablab_group: 'bar:baz,foo:a' }
        allow(request).to receive(:params).and_return(params)
        run = Ablab::Run.new(experiment, '6q5wed', request)
        expect(run.group).to eq(:a)
      end
    end

    describe "#track_view!" do
      it "tracks the view" do
        expect(Ablab.tracker).to receive(:track_view!)
          .with(run.experiment.name, run.group, run.session_id)
        run.track_view!
      end

      it "performs callbacks" do
        x = nil
        y = nil
        allow(Ablab).to receive(:callbacks) {
          [ -> (*args) { y = args } ]
        }
        experiment.on_track do |event, experiment, group, session, request|
          x = [event, experiment, group, session, request]
        end
        run.track_view!
        expect(x).to eq([:view, :foo, run.group, run.session_id, request])
        expect(y).to eq([:view, :foo, run.group, run.session_id, request])
      end
    end

    describe "#track_success!" do
      it "tracks the success" do
        expect(Ablab.tracker).to receive(:track_success!)
          .with(run.experiment.name, run.group, run.session_id)
        run.track_success!
      end

      it "performs callbacks" do
        x = nil
        y = nil
        allow(Ablab).to receive(:callbacks) {
          [ -> (*args) { y = args } ]
        }
        experiment.on_track do |event, experiment, group, session, request|
          x = [event, experiment, group, session, request]
        end
        run.track_success!
        expect(x).to eq([:success, :foo, run.group, run.session_id, request])
        expect(y).to eq([:success, :foo, run.group, run.session_id, request])
      end
    end
  end
end
