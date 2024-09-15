# frozen_string_literal: true

require "spec_helper"

RSpec.describe AceConfig do
  describe "#configure" do
    let(:dummy_module) { Module.new { extend AceConfig } }

    context "when using a block" do
      it "configures settings correctly" do
        dummy_module.configure(:app_config) do
          config username: "admin"
          config max_connections: 10, type: :int
        end

        expect(dummy_module.app_config.username).to eq("admin")
      end
    end

    context "when loading from a hash" do
      it "loads settings from a hash" do
        dummy_module.configure :app_config, hash: { username: "admin", max_connections: 10 }

        aggregate_failures do
          expect(dummy_module.app_config.username).to eq("admin")
          expect(dummy_module.app_config.max_connections).to eq(10)
        end
      end
    end

    context "when loading from JSON" do
      let(:json_data) { { username: "admin", max_connections: 10 }.to_json }

      it "loads settings from JSON" do
        dummy_module.configure(:app_config, json: json_data)

        aggregate_failures do
          expect(dummy_module.app_config.username).to eq("admin")
          expect(dummy_module.app_config.max_connections).to eq(10)
        end
      end
    end

    context "when loading from YAML" do
      before do
        yaml_helper_tempfile do |temp_file|
          dummy_module.configure(:app_config, yaml: temp_file.path)
        end
      end

      it "loads settings from YAML" do
        aggregate_failures do
          expect(dummy_module.app_config.username).to eq("admin")
          expect(dummy_module.app_config.max_connections).to eq(10)
        end
      end
    end

    context "when loading from invalid formats" do
      it "raises LoadDataError for invalid JSON format" do
        expect do
          dummy_module.configure(:app_config, json: "{invalid_json}")
        end.to raise_error(AceConfig::LoadDataError, "Invalid JSON format")
      end

      it "raises LoadDataError for non-existent YAML file" do
        expect do
          dummy_module.configure(:app_config, yaml: "non_existent.yml")
        end.to raise_error(AceConfig::LoadDataError, "YAML file not found")
      end

      it "raises LoadDataError for empty options" do
        expect do
          dummy_module.configure(:app_config, file: "non_supported.txt")
        end.to raise_error(AceConfig::LoadDataError, "Invalid load source type")
      end
    end

    context "when no options are provided" do
      it "does not load any settings" do
        dummy_module.configure(:app_config)

        expect(dummy_module.respond_to?(:app_config)).to be true
      end
    end
  end
end
