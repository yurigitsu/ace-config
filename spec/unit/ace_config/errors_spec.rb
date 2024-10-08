# frozen_string_literal: true

require "spec_helper"

RSpec.describe "AceConfig::Errors" do
  describe "SettingTypeError" do
    it "sets the error message correctly" do
      error = AceConfig::SettingTypeError.new(:int, "string")
      expect(error.message).to eq("Expected: <int>. Given: \"string\" which is <String> class.")
    end

    it "handles nil value correctly" do
      error = AceConfig::SettingTypeError.new(:int, nil)
      expect(error.message).to eq("Expected: <int>. Given: nil which is <NilClass> class.")
    end

    it "handles array input correctly" do
      error = AceConfig::SettingTypeError.new(:int, [1, 2, 3])
      expect(error.message).to eq("Expected: <int>. Given: [1, 2, 3] which is <Array> class.")
    end
  end

  describe "TypeCheckerError" do
    it "sets the error message correctly" do
      error = AceConfig::TypeCheckerError.new(:unknown_type)
      expect(error.message).to eq("No type Definition for: <unknown_type> type")
    end

    it "handles known type with nil correctly" do
      error = AceConfig::TypeCheckerError.new(nil)
      expect(error.message).to eq("No type Definition for: <> type")
    end

    it "handles empty string type correctly" do
      error = AceConfig::TypeCheckerError.new("")
      expect(error.message).to eq("No type Definition for: <> type")
    end
  end

  describe "LoadDataError" do
    it "sets the error message correctly" do
      error = AceConfig::LoadDataError.new("Data loading failed")
      expect(error.message).to eq("Data loading failed")
    end

    it "handles empty message correctly" do
      error = AceConfig::LoadDataError.new("")
      expect(error.message).to eq("")
    end

    it "handles nil message correctly" do
      error = AceConfig::LoadDataError.new("AceConfig::LoadDataError")
      expect(error.message).to eq("AceConfig::LoadDataError")
    end
  end
end
