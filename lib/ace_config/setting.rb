# frozen_string_literal: true

require "yaml"
require "json"

# AceConfig module provides functionality for managing AceConfig features.
module AceConfig
  # Setting class provides a configuration tree structure for managing settings.
  #
  # This class allows for dynamic configuration management, enabling
  # the loading of settings from hashes, YAML, or JSON formats.
  #
  # @example Basic usage
  #   settings = Setting.new do
  #     config(:key1, value: "example")
  #     config(:key2, type: :int)
  #   end
  #
  class Setting
    # Dynamically define methods for each type in TypeMap.
    #
    # @!method int(value)
    #   Sets an integer configuration value.
    #   @param value [Integer] The integer value to set.
    #
    # @!method string(value)
    #   Sets a string configuration value.
    #   @param value [String] The string value to set.
    #
    # ... (other type methods)
    AceConfig::TypeMap.list_types.each do |type|
      define_method(type.downcase) do |stng, lock = nil|
        params = { type: type }.tap { |obj| obj.merge!(lock: lock) if lock.nil? }
        config(stng, **params)
      end
    end

    # Initializes a new Setting instance.
    #
    # @yield [self] Configures the instance upon creation if a block is given.
    def initialize(&block)
      @config_tree = {}
      @schema = {}
      @immutable_schema = {}

      instance_eval(&block) if block_given?
    end

    # Loads configuration from a hash with an optional schema.
    #
    # @param data [Hash] The hash containing configuration data.
    # @param schema [Hash] Optional schema for type validation.
    # @raise [NoMethodError] If a method corresponding to a key is not defined.
    # @raise [SettingTypeError] If a value doesn't match the specified type in the schema.
    #
    # @example Loading from a hash with type validation
    #   settings.load_from_hash({ name: "admin", max_connections: 10 }, schema: { name: :str, max_connections: :int })
    def load_from_hash(data, schema: {}, lock_schema: {})
      data.each do |key, value|
        key = key.to_sym
        type = schema[key] if schema
        lock = lock_schema[key] if lock_schema

        if value.is_a?(Hash) || value.is_a?(Setting)
          configure(key) { load_from_hash(value, schema: schema[key], lock_schema: lock_schema[key]) }
        else
          validate_mutable!(key, lock) if lock
          validate_setting!(value, type) if type

          config(key => value, type: type, lock: lock)
        end
      end
    end

    # Configures a node of the configuration tree.
    #
    # @param node [Symbol, String] The name of the config node key.
    # @yield [Setting] A block that configures the new node.
    #
    # @example Configuring a new node
    #   settings.configure(:database) do
    #     config(:host, value: "localhost")
    #     config(:port, value: 5432)
    #   end
    def configure(node, &block)
      if config_tree[node]
        config_tree[node].instance_eval(&block)
      else
        create_new_node(node, &block)
      end
    end

    # Configures a setting with a given name and type.
    #
    # @param setting [Symbol, Hash, nil] The name of the setting or a hash of settings.
    # @param type [Symbol, nil] The expected type of the setting.
    # @param opt [Hash] Additional options for configuration.
    # @return [self] The current instance for method chaining.
    # @raise [SettingTypeError] If the value does not match the expected type.
    #
    # @example Configuring a setting
    #   settings.config(max_connections: 10, type: :int)
    def config(setting = nil, type: nil, lock: nil, **opt)
      return self if !setting && opt.empty?

      raw_stngs = setting || opt
      stngs = extract_setting_info(raw_stngs)

      # binding.pry

      stng_lock = lock.nil? ? stngs[:lock] : lock
      stng_lock = immutable_schema[stngs[:name]] if stng_lock.nil?

      stng_type = type || schema[stngs[:name]] || :any

      validate_mutable!(stngs[:name], stng_lock) if stngs[:value] && config_tree[stngs[:name]] && !lock
      validate_setting!(stngs[:value], stng_type)

      set_configuration(stng_name: stngs[:name], stng_val: stngs[:value], stng_type: stng_type, stng_lock: stng_lock)
    end

    # Returns the type schema of the configuration.
    #
    # @return [Hash] A hash representing the type schema.
    # @example Retrieving the type schema
    #   schema = settings.type_schema
    def type_schema
      {}.tap do |hsh|
        config_tree.each do |k, v|
          v.is_a?(AceConfig::Setting) ? (hsh[k] = v.type_schema) : hsh.merge!(schema)
        end
      end
    end

    def lock_schema
      {}.tap do |hsh|
        config_tree.each do |k, v|
          v.is_a?(AceConfig::Setting) ? (hsh[k] = v.lock_schema) : hsh.merge!(immutable_schema)
        end
      end
    end

    # Converts the configuration tree into a hash.
    #
    # @return [Hash] The config tree as a hash.
    # @example Converting to hash
    #   hash = settings.to_h
    def to_h
      {}.tap do |hsh|
        config_tree.each do |k, v|
          hsh[k] = v.is_a?(AceConfig::Setting) ? v.to_h : v
        end
      end
    end

    # Converts the configuration tree into YAML format.
    #
    # @param dump [String, nil] Optional file path to dump the YAML.
    # @return [String, nil] The YAML string or nil if dumped to a file.
    # @example Converting to YAML
    #   yaml_string = settings.to_yaml
    #   settings.to_yaml(dump: "config.yml") # Dumps to a file
    def to_yaml(dump: nil)
      yaml = to_h.to_yaml
      dump ? File.write(dump, yaml) : yaml
    end

    # Converts the configuration tree into JSON format.
    #
    # @return [String] The JSON representation of the configuration tree.
    # @example Converting to JSON
    #   json_string = settings.to_json
    def to_json(*_args)
      to_h.to_json
    end

    protected

    # @return [Hash] The schema of configuration types.
    attr_reader :schema, :immutable_schema

    private

    # @return [Hash] The tree structure of configuration settings.
    attr_reader :config_tree

    # Creates a new node in the configuration tree.
    #
    # @param node [Symbol] The name of the node to create.
    # @yield [Setting] A block to configure the new setting.
    # @return [Setting] The newly created setting node.
    def create_new_node(node, &block)
      new_node = AceConfig::Setting.new(&block)
      config_tree[node] = new_node
      define_node_methods(node)
    end

    # Defines singleton methods for the given node.
    #
    # @param node [Symbol] The name of the node to define methods for.
    def define_node_methods(node)
      define_singleton_method(node) do |*_args, &node_block|
        if node_block
          config_tree[node].instance_eval(&node_block)
        else
          config_tree[node]
        end
      end
    end

    # Extracts the setting information from the provided input.
    #
    # @param stngs [Symbol, Hash] The setting name or a hash containing the setting name and value.
    # @return [Hash] A hash containing the setting name and its corresponding value.
    def extract_setting_info(stngs)
      val = nil
      lock = nil

      name = stngs if stngs.is_a?(Symbol)

      if stngs.is_a?(Hash)
        lock = stngs.delete(:lock)
        name, val = stngs.to_a.first
      end

      { name: name, value: val, lock: lock }
    end

    # Validates the setting value against the expected type.
    #
    # @param stng_val [Object] The value of the setting to validate.
    # @param stng_type [Symbol] The expected type of the setting.
    # @raise [SettingTypeError] If the setting value does not match the expected type.
    def validate_setting!(stng_val, stng_type)
      is_valid = AceConfig::TypeChecker.call(stng_val, type: stng_type)
      raise AceConfig::SettingTypeError.new(stng_type, stng_val) unless !stng_val || is_valid
    end

    def validate_mutable!(name, stng_lock)
      raise "<#{name}> setting is immutable" if stng_lock
    end

    # Sets the configuration for a given setting name, value, and type.
    #
    # @param stng_name [Symbol] The name of the setting to configure.
    # @param stng_val [Object] The value to assign to the setting.
    # @param stng_type [Symbol] The type of the setting.
    def set_configuration(stng_name:, stng_val:, stng_type:, stng_lock:)
      schema[stng_name] = stng_type
      config_tree[stng_name] = stng_val
      immutable_schema[stng_name] = stng_lock

      return if respond_to?(stng_name)

      define_singleton_method(stng_name) do |value = nil, type: nil, lock: nil|
        return config_tree[stng_name] unless value

        config(**{ stng_name => value, type: type, lock: lock })
      end
    end
  end
end
