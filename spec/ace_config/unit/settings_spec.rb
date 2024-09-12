require "spec_helper"

# [WIP:]

RSpec.describe Setting do
  let(:setting) { Setting.new }

  describe "#initialize" do
    it "initializes with a block and configures settings" do
      settings = Setting.new do
        config username: "admin"
        config max_connections: 10, type: :int
      end

      expect(settings.username).to eq("admin")
      expect(settings.max_connections).to eq(10)
      expect(settings.type_schema).to include(username: :any, max_connections: :int)
    end

    it "does not raise an error when no block is given" do
      expect { Setting.new }.not_to raise_error
    end
  end

  describe '#configure' do
    it 'configures a new node in the configuration tree' do
      setting.configure :new_node do
        config key: 'value'
      end

      expect(setting.new_node).to be_a(Setting)
      expect(setting.new_node.key).to eq('value')
    end
  end

  describe '#config' do
    it 'raises an error for invalid type' do
      expect { setting.config(key: 'value', type: :int) }.to raise_error(SettingTypeError)
    end

    it 'stores valid configuration' do
      setting.config(key: 'value')

      expect(setting.key).to eq('value')
    end
  end

  describe '#to_h' do
    it 'converts the configuration tree to a hash' do
      setting.config(key: 'value')

      expect(setting.to_h).to eq({ key: 'value' })
    end
  end

  describe '#to_yaml' do
    it 'converts the configuration tree to YAML' do
      setting.config(key: 'value')

      expect(setting.to_yaml).to include('key: value')
    end
  end

  describe '#to_json' do
    it 'converts the configuration tree to JSON' do
      setting.config(key: 'value')

      expect(setting.to_json).to include('"key":"value"')
    end
  end

  describe '#type_schema' do
    it 'returns the type schema of the configuration' do
      setting.config(key1: 'value1', type: :str)
      setting.config(key2: 42, type: :int)      
      expected_schema = { key1: :str, key2: :int }

      expect(setting.type_schema).to eq(expected_schema)
    end

    it 'returns an empty hash when no configurations are set' do
      expect(setting.type_schema).to eq({})
    end

    it 'handles nested settings' do
      setting.configure :nested do
        config key3: 'value3', type: :str
      end

      expected_schema = { key3: :str }

      expect(setting.nested.type_schema).to eq(expected_schema)
    end
  end
end
