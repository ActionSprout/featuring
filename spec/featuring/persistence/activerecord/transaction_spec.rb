# frozen_string_literal: true

require_relative "./helpers"

RSpec.describe "persisting multiple feature flags on an activerecord model" do
  include_context :activerecord

  let(:features) {
    Module.new do
      extend Featuring::Declarable
      feature :foo
      feature :bar
      feature :baz do |value|
        value == :baz
      end
      feature :qux
      feature :quux
    end
  }

  def perform
    instance.features.transaction do |features|
      features.set :foo, true
      features.set :bar, false
      features.persist :baz, :baz
      features.disable :qux
      features.enable :quux
    end
  end

  context "instance has no persisted feature flags" do
    before do
      allow(feature_flag_model).to receive(:create)
      allow(feature_flag_model).to receive(:find_by)

      perform
    end

    it "creates the flags at once" do
      expect(feature_flag_model).to have_received(:create).with(
        flaggable_id: instance_id,
        flaggable_type: model.name,
        metadata: {
          foo: true,
          bar: false,
          baz: true,
          qux: false,
          quux: true
        }
      )
    end
  end

  context "feature flag is already set" do
    include_context :existing_feature_flag

    before do
      perform
    end

    it "updates the flags at once" do
      expect(feature_flag_model_connection).to have_received(:execute).with(
        "UPDATE \"feature_flags\" SET metadata = metadata || '{\"foo\":true,\"bar\":false,\"baz\":true,\"qux\":false,\"quux\":true}' WHERE \"feature_flags\".\"flaggable_type\" = 'ModelWithFeatures' AND \"feature_flags\".\"flaggable_id\" = 123"
      )
    end
  end
end
