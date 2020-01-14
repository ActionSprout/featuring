# frozen_string_literal: true

require "featuring/persistence"

module Featuring
  module Persistence
    # Persist multiple feature flag values for an object at once.
    #
    # @example
    #   class User < ActiveRecord::Base
    #     extend Featuring::Persistence::ActiveRecord
    #
    #     extend Featuring::Declarable
    #     feature :feature_1
    #     feature :feature_2
    #   end
    #
    #   User.find(1).features.transaction do |features|
    #     features.enable :feature_1
    #     features.disable :feature_2
    #   end
    #
    #   User.find(1).features.feature_1?
    #   => true
    #
    #   User.find(1).features.feature_2?
    #   => false
    #
    class Transaction
      # @api private
      attr_reader :values

      def initialize(features)
        @features = features
        @values = {}
      end

      # Persists the default or computed value for a feature flag within a transaction.
      #
      # See {Featuring::Persistence::Adapter::Methods#persist}
      #
      def persist(feature, *args)
        @values[feature.to_sym] = @features.public_send(:"#{feature}?", *args)
      end

      # Sets the value for a feature flag within a transaction.
      #
      # See {Featuring::Persistence::Adapter::Methods#set}
      #
      def set(feature, value)
        @values[feature.to_sym] = !!value
      end

      # Enables a feature flag.
      #
      # See {Featuring::Persistence::Adapter::Methods#enable}
      #
      def enable(feature)
        @values[feature.to_sym] = true
      end

      # Disables a feature flag.
      #
      # See {Featuring::Persistence::Adapter::Methods#disable}
      #
      def disable(feature)
        @values[feature.to_sym] = false
      end
    end
  end
end
