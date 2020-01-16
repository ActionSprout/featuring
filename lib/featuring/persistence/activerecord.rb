# frozen_string_literal: true

require "featuring/persistence"
require "featuring/persistence/adapter"

module Featuring
  module Persistence
    # Persists feature flag values using an ActiveRecord model. Postgres is currently the only
    # supported database.
    #
    # See {Featuring::Persistence} for details on how to use feature flag persistence.
    #
    # @example
    #   class User < ActiveRecord::Base
    #     extend Featuring::Persistence::ActiveRecord
    #
    #     extend Featuring::Declarable
    #     feature :some_feature
    #   end
    #
    #   User.find(1).features.enable :some_feature
    #   User.find(1).features.some_feature?
    #   => true
    #
    module ActiveRecord
      extend Adapter

      # Methods to be added to the flaggable object.
      #
      module Flaggable
        def reload
          features.reload

          super
        end
      end

      # Returns the ActiveRecord model used to persist feature flag values.
      #
      def feature_flag_model
        ::FeatureFlag
      end

      class << self
        # @api private
        def fetch(target)
          target.feature_flag_model.find_by(flaggable_id: target.id, flaggable_type: target.class.name)&.metadata
        end

        # @api private
        def create(target, **features)
          target.feature_flag_model.create(
            flaggable_id: target.id,
            flaggable_type: target.class.name,
            metadata: features,
          )
        end

        # @api private
        def update(target, **features)
          scoped_dataset(target).update_all("metadata = metadata || '#{features.to_json}'")
        end

        # @api private
        def replace(target, **features)
          scoped_dataset(target).update_all("metadata = '#{features.to_json}'")
        end

        private def scoped_dataset(target)
          target.feature_flag_model.where(
            flaggable_type: target.class.name,
            flaggable_id: target.id,
          )
        end
      end
    end
  end
end
