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
    AceConfig::TypeMap.list_types.each do |type|
      # Dynamically define methods for each type in TypeMap.
      #
      # @param stng [Object] The value to set for the configuration.
      define_method(type.downcase) { |stng| config(stng, type: type) }
    end

    # Initializes a new Setting instance.
    #
    # @yield [self] Optional block to configure the instance upon creation.
    def initialize(&block)
      @schema = {}
      @config_tree = {}

      instance_eval(&block) if block_given?
    end

    # Loads configuration from a hash.
    #
    # @param data [Hash] The hash containing configuration data.
    # @raise [NoMethodError] if a method corresponding to a key is not defined.
    #
    # @example Loading from a hash
    #   settings = Setting.new
    #   settings.load_from_hash({ username: "admin", password: "secret" })
    #   puts settings.username # => "admin"
    #   puts settings.password # => "secret"
    def load_from_hash(data)
      data.each do |key, value|
        if value.is_a?(Hash) || value.is_a?(Setting)
          configure(key) { load_from_hash(value) }
        else
          config(key => value)
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
    #   puts settings.database.host # => "localhost"
    #   puts settings.database.port # => 5432
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
    # @raise [SettingTypeError] if the value does not match the expected type.
    #
    # @example Configuring a setting
    #   settings.config max_connections: 10, type: :int
    def config(setting = nil, type: nil, **opt)
      return self if !setting && opt.empty?

      stngs = setting || opt
      stng = extract_setting_info(stngs)

      stng_type = type || schema[stng[:name]] || :any
      validate_setting!(stng[:value], stng_type)

      set_configuration(stng[:name], stng[:value], stng_type)
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
    attr_reader :schema

    private

    # @return [Hash] The tree structure of configuration settings.
    attr_reader :config_tree

    # Creates a new node in the configuration tree.
    #
    # @param node [Symbol] The name of the node to create.
    # @yield [Setting] A block to configure the new setting.
    # @return [Setting] The newly created setting node.
    #
    # @example Creating a new node
    #   create_new_node(:my_setting) do
    #     # configuration for my_setting
    #   end
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
    #
    # @example
    #   extract_setting_info(:my_setting) # => { name: :my_setting, value: nil }
    #   extract_setting_info({ my_setting: 10 }) # => { name: :my_setting, value: 10 }
    def extract_setting_info(stngs)
      val = nil
      name = stngs if stngs.is_a?(Symbol)
      name, val = stngs.to_a.first if stngs.is_a?(Hash)

      { name: name, value: val }
    end

    # Validates the setting value against the expected type.
    #
    # @param stng_val [Object] The value of the setting to validate.
    # @param stng_type [Symbol] The expected type of the setting.
    # @raise [SettingTypeError] If the setting value does not match the expected type.
    #
    # @example
    #   validate_setting!(10, :int) # Validates successfully
    #   validate_setting!("string", :int) # Raises SettingTypeError
    def validate_setting!(stng_val, stng_type)
      is_valid = AceConfig::TypeChecker.call(stng_val, type: stng_type)
      raise AceConfig::SettingTypeError.new(stng_type, stng_val) unless !stng_val || is_valid
    end

    # Sets the configuration for a given setting name, value, and type.
    #
    # @param stng_name [Symbol] The name of the setting to configure.
    # @param stng_val [Object] The value to assign to the setting.
    # @param stng_type [Symbol] The type of the setting.
    #
    # @example
    #   set_configuration(:max_connections, 10, :int)
    def set_configuration(stng_name, stng_val, stng_type)
      schema[stng_name] = stng_type
      config_tree[stng_name] = stng_val
      return if respond_to?(stng_name)

      define_singleton_method(stng_name) do |value = nil, type: nil|
        if value
          config(**{ stng_name => value, type: type })
        else
          config_tree[stng_name]
        end
      end
    end
  end
end
