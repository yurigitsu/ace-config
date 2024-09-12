require "spec_helper"
require 'tempfile'

RSpec.describe AceDeck do
  describe '#configure' do
    let(:dummy_module) { Module.new { extend AceDeck } }

    context 'when using a block' do
      it 'configures settings correctly' do
        dummy_module.configure(:app_config) do
          config username: "admin"
          config max_connections: 10, type: :int
        end

        expect(dummy_module.app_config.username).to eq("admin")
      end
    end

    context 'when loading from a hash' do
      it 'loads settings from a hash' do
        dummy_module.configure(:app_config, hash: { username: "admin", max_connections: 10 })

        expect(dummy_module.app_config.username).to eq("admin")
        expect(dummy_module.app_config.max_connections).to eq(10)
      end
    end

    context 'when loading from JSON' do
      it 'loads settings from JSON' do
        json_data = {"username": "admin", "max_connections": 10}.to_json
        dummy_module.configure(:app_config, json: json_data)

        expect(dummy_module.app_config.username).to eq("admin")
        expect(dummy_module.app_config.max_connections).to eq(10)
      end
    end

    context 'when loading from YAML' do
      it 'loads settings from YAML' do
        Tempfile.create(['config', '.yml']) do |temp_file|
          temp_file.write({ username: "admin", max_connections: 10 }.to_yaml)
          temp_file.rewind
          dummy_module.configure(:app_config, yaml: temp_file.path)
        end

        expect(dummy_module.app_config.username).to eq("admin")
        expect(dummy_module.app_config.max_connections).to eq(10)
      end
    end

    context 'when no options are provided' do
      it 'does not load any settings' do
        dummy_module.configure(:app_config)

        expect(dummy_module.respond_to?(:app_config)).to be true
      end
    end
  end
end
