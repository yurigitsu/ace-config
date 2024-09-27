# frozen_string_literal: true

# AceConfig module provides functionality for managing AceConfig features.
module AceConfig
  def self.included(base)
    base.extend(Configuration)
  end

  # This module handles configuration trees and loading data from various sources.
  module Configuration
    # Creates a class-level method for the configuration tree.
    #
    # This method allows you to define a configuration tree using a block
    # or load configuration data from a hash, JSON, or YAML file.
    #
    # @param config_tree_name [Symbol, String] The name of the configuration method to be defined.
    # @param opts [Hash] Optional options for loading configuration data.
    # @option opts [Hash] :hash A hash containing configuration data.
    # @option opts [String] :json A JSON string containing configuration data.
    # @option opts [String] :yaml A file path to a YAML file containing configuration data.
    # @yield [Setting] A block that builds the configuration tree.
    #
    # @example Configuring with a block
    #   configure :app_config do
    #     config :username, value: "admin"
    #     config :max_connections, type: :int, value: 10
    #   end
    #
    # @example Loading from a hash
    #   configure :app_config, hash: { username: "admin", max_connections: 10 }
    #
    # @example Loading from a JSON string
    #   configure :app_config, json: '{"username": "admin", "max_connections": 10}'
    #
    # @example Loading from a YAML file
    #   configure :app_config, yaml: 'config/settings.yml'
    def configure(config_tree_name, opts = {}, &block)
      settings = block ? AceConfig::Setting.new(&block) : AceConfig::Setting.new

      load_configs = load_data(opts) unless opts.empty?
      settings.load_from_hash(load_configs) if load_configs

      define_singleton_method(config_tree_name) do |&tree_block|
        tree_block ? settings.instance_eval(&tree_block) : settings
      end

      self
    end

    module Check
      class A
        include AceConfig

        configure :a do
          config b: 1
        end
      end

      class B < A; end

      # B.a { b 2 }
    end

    module_function

    # Loads configuration data from various sources based on the provided options.
    #
    # @param opts [Hash] Optional options for loading configuration data.
    # @option opts [Hash] :hash A hash containing configuration data.
    # @option opts [String] :json A JSON string containing configuration data.
    # @option opts [String] :yaml A file path to a YAML file containing configuration data.
    # @return [Hash] The loaded configuration data.
    # @raise [LoadDataError] If no valid data is found.
    #
    # @example Loading from a hash
    #   load_data(hash: { key: "value" })
    #
    # @example Loading from a JSON string
    #   load_data(json: '{"key": "value"}')
    #
    # @example Loading from a YAML file
    #   load_data(yaml: 'config/settings.yml')
    def load_data(opts = {})
      data = opts[:hash] if opts[:hash]
      data = JSON.parse(opts[:json]) if opts[:json]
      data = YAML.load_file(opts[:yaml]) if opts[:yaml]
      raise AceConfig::LoadDataError, "Invalid load source type" unless data

      data
    rescue JSON::ParserError
      raise AceConfig::LoadDataError, "Invalid JSON format"
    rescue Errno::ENOENT
      raise AceConfig::LoadDataError, "YAML file not found"
    end
  end
end
