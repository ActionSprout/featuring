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
          target.feature_flag_model.connection.execute(build_update_sql(target.feature_flag_model.table_name, target, **features))
        end

        private def build_update_sql(table_name, target, **features)
          table = Arel::Table.new(table_name)
          update = Arel::UpdateManager.new(table.engine)
          update.table(table)
          update.set(Arel::Nodes::SqlLiteral.new("metadata = metadata || '#{features.to_json}'"))
          update.where(table[:flaggable_type].eq(target.class))
          update.where(table[:flaggable_id].eq(target.id))
          update.to_sql
        end
      end
    end
  end
end
