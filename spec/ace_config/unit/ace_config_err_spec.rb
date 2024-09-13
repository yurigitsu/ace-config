# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Errors" do
  describe "SettingTypeError" do
    it "sets the error message correctly" do
      error = AceConfigErr::SettingTypeError.new(:int, "string")
      expect(error.message).to eq("Expected: <int>. Given: \"string\" which is <String> class.")
    end

    it "handles nil value correctly" do
      error = AceConfigErr::SettingTypeError.new(:int, nil)
      expect(error.message).to eq("Expected: <int>. Given: nil which is <NilClass> class.")
    end

    it "handles array input correctly" do
      error = AceConfigErr::SettingTypeError.new(:int, [1, 2, 3])
      expect(error.message).to eq("Expected: <int>. Given: [1, 2, 3] which is <Array> class.")
    end
  end

  describe "TypeCheckerError" do
    it "sets the error message correctly" do
      error = AceConfigErr::TypeCheckerError.new(:unknown_type)
      expect(error.message).to eq("No type Definition for: <unknown_type> type")
    end

    it "handles known type with nil correctly" do
      error = AceConfigErr::TypeCheckerError.new(nil)
      expect(error.message).to eq("No type Definition for: <> type")
    end

    it "handles empty string type correctly" do
      error = AceConfigErr::TypeCheckerError.new("")
      expect(error.message).to eq("No type Definition for: <> type")
    end
  end

  describe "LoadDataError" do
    it "sets the error message correctly" do
      error = AceConfigErr::LoadDataError.new("Data loading failed")
      expect(error.message).to eq("Data loading failed")
    end

    it "handles empty message correctly" do
      error = AceConfigErr::LoadDataError.new("")
      expect(error.message).to eq("")
    end

    it "handles nil message correctly" do
      error = AceConfigErr::LoadDataError.new("AceConfigErr::LoadDataError")
      expect(error.message).to eq("AceConfigErr::LoadDataError")
    end
  end
end
