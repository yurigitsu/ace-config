# frozen_string_literal: true

# AceConfig module provides functionality for managing configuration features.
#
# @example Using AceConfiguration in a class
#   class MyApp
#     include AceConfiguration
#
#     configure :settings do
#       config api_key: "default_key"
#       config max_retries: 3
#     end
#   end
#
#   MyApp.settings.api_key # => "default_key"
#   MyApp.settings.max_retries # => 3
#
# @example Configuring with a block
#   class AnotherApp
#     include AceConfiguration
#
#     configure :app_settings do
#       config feature_enabled: true
#       config max_users: 100
#     end
#   end
#
#   AnotherApp.app_settings.feature_enabled # => true
#   AnotherApp.app_settings.max_users # => 100
module AceConfiguration
  # Extends the base class with AceConfig::Configuration module methods
  #
  # @param base [Class] The class including this module
  # @return [void]
  def self.included(base)
    # base.include(AceConfig::Configuration)
    base.extend InstanceConfig
    base.include InstanceConfig
  end

  # Modify constructor ?

  module InstanceConfig
    def configure(config_tree_name, opts = {}, &block)
      settings = block ? AceConfig::Setting.new(&block) : AceConfig::Setting.new

      load_configs = AceConfig::Configuration.load_data(opts) unless opts.empty?
      settings.load_from_hash(load_configs, schema: opts[:schema], lock_schema: opts[:lock_schema]) if load_configs

      @isolated_configs ||= []
      @isolated_configs << { config_tree_name => settings }

      define_method(config_tree_name) do |&tree_block|
        tree_block ? settings.instance_eval(&tree_block) : settings
      end
    end

    def inherited(base)
      super

      @isolated_configs.map do |elem|
        elem.each do |name, configs|
          base.configure name, hash: configs.to_h, schema: configs.type_schema, lock_schema: configs.lock_schema
        end
      end
    end
  end

  # Extends the base class with AceConfig::Configuration module methods
  #
  # @param base [Class] The class extending this module
  # @return [void]
  def self.extended(base)
    base.extend(AceConfig::Configuration)
  end

  # Isolated module handles isolated configurations.
  #
  # This module allows for configuration inheritance while maintaining
  # isolation between parent and child configurations.
  #
  # @example Using Isolated configurations
  #   class ParentApp
  #     include AceConfiguration::Isolated
  #
  #     configure :parent_settings do
  #       config timeout: 30
  #       config tries: 3
  #     end
  #   end
  #
  #   class ChildApp < ParentApp
  #     parent_settings do
  #       config tries: 4
  #     end
  #   end
  #
  #   ChildApp.parent_settings.timeout # => 30
  #   ChildApp.parent_settings.tries # => 4
  #   ParentApp.parent_settings.tries # => 3
  #
  # @example Configuring a child class
  #   class AnotherChildApp < ParentApp
  #     parent_settings do
  #       config timeout: 60
  #     end
  #   end
  #
  #   AnotherChildApp.parent_settings.timeout # => 60
  #   AnotherChildApp.parent_settings.tries # => 3
  module Local
    # Extends the base class with AceConfig::Configuration and AceConfig::Configuration::Isolated module methods
    #
    # @param base [Class] The class extending this module
    # @return [void]
    def self.extended(base)
      base.extend(AceConfig::Configuration)
      base.extend(AceConfig::Configuration::Local)
    end
  end
end
