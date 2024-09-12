# frozen_string_literal: true

require "yaml"
require "json"

# Setting class. Provides configuration tree.
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
  TypeMap.list_types.each do |type|
    # Dynamically define methods for each type in TypeMap.
    #
    # @param stng [Object] The value to set for the configuration.
    define_method(type.downcase) { |stng| config(stng, type: type) }
  end

  # @return [Hash] The schema of configuration types.
  protected attr_reader :schema

  # @return [Hash] The tree structure of configuration settings.
  private attr_reader :config_tree


  # Initializes a new Setting instance.
  #
  # @yield [self] Optional block to configure the instance upon creation.
  # @example Initializing with a block
  #   settings = Setting.new do
  #     config(:username, value: "admin")
  #   end
  def initialize(&)
    @schema = {}
    @config_tree = {}

    instance_eval(&) if block_given?
  end

  # Loads configuration from a hash.
  #
  # @param data [Hash] The hash containing configuration data.
  # @raise [NoMethodError] if a method corresponding to a key is not defined.
  #
  # @example Loading from a hash
  #   settings = Setting.new
  #   settings.load_from_hash({ username: "admin", password: "secret" })
  def load_from_hash(data)
    data.each do |key, value|
      if value.is_a?(Hash) || value.is_a?(Setting)
        configure(key) { load_from_hash(value) }
      else
        config(key => value)
      end
    end
  end

  # Configure a node of the configuration tree.
  #
  # @param node [Symbol, String] The name of the config node key.
  # @param value [Object] Optional value for the node.
  # @yield [Setting] A block that configures the new node.
  #
  # @example Configuring a new node
  #   settings.configure(:database) do
  #     config(:host, value: "localhost")
  #     config(:port, value: 5432)
  #   end
  def configure(node, value = nil, &)
    if config_tree[node]
      config_tree[node].instance_eval(&)
    else
      new_node = Setting.new(&)
      config_tree[node] = new_node

      define_singleton_method(node) do |*args, &node_block|
        if node_block
          config_tree[node].instance_eval(&node_block)
        else
          config_tree[node]
        end
      end
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
  #  @example Configuring a setting``
  #   settings.config(:max_connections, type: :int, value: 10)
  def config(setting = nil, type: nil, **opt)
    return self if !setting && opt.empty?

    stngs = setting || opt

    stng_name, stng_val = stngs, nil if stngs.is_a?(Symbol)
    stng_name, stng_val = stngs.to_a.first if stngs.is_a?(Hash)

    stng_type = type || schema[stng_name] || :any

    is_valid = TypeChecker.call(stng_val, type: stng_type)
    raise SettingTypeError.new(stng_type, stng_val) unless !stng_val || is_valid

    schema[stng_name] = stng_type
    config_tree[stng_name] = stng_val
    define_singleton_method(stng_name) { config_tree[stng_name] }
  end

  # Returns the type schema of the configuration.
  #
  # @return [Hash] A hash representing the type schema.
  # @example Retrieving the type schema
  #   schema = settings.type_schema
  def type_schema
    {}.tap do |hsh|
      config_tree.each do |k, v|
        v.is_a?(Setting) ? (hsh[k] = v.type_schema) : hsh.merge!(schema)
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
        hsh[k] = v.is_a?(Setting) ? v.to_h : v
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
  def to_json
    to_h.to_json
  end
end
