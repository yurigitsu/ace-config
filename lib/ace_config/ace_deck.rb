# frozen_string_literal: true

module AceDeck
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
    settings = block ? Setting.new(&block) : Setting.new

    # [WIP:]
    if !opts.empty?
      data = opts[:hash] if opts[:hash]
      data = JSON.load(opts[:json]) if opts[:json]
      data = YAML.load_file(opts[:yaml]) if opts[:yaml]

      raise "Invalid file type" unless data

      settings.load_from_hash(data)
    end

    anonym_module = Module.new

    anonym_module.define_method(config_tree_name) do |&tree_block|
      tree_block ? settings.instance_eval(&tree_block) : settings
    end

    extend anonym_module
  end
end
