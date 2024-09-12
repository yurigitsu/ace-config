require "spec_helper"

RSpec.describe 'Errors' do  
  describe "SettingTypeError" do
    it "sets the error message correctly" do
      error = SettingTypeError.new(:int, "string")
      expect(error.message).to eq("Expected: <int>. Given: \"string\" which is <String> class.")
    end

    it "handles nil value correctly" do
      error = SettingTypeError.new(:int, nil)
      expect(error.message).to eq("Expected: <int>. Given: nil which is <NilClass> class.")
    end

    it "handles array input correctly" do
      error = SettingTypeError.new(:int, [1, 2, 3])
      expect(error.message).to eq("Expected: <int>. Given: [1, 2, 3] which is <Array> class.")
    end
  end

  describe "TypeCheckerError" do
    it "sets the error message correctly" do
      error = TypeCheckerError.new(:unknown_type)
      expect(error.message).to eq("No type Definition for: <unknown_type> type")
    end

    it "handles known type with nil correctly" do
      error = TypeCheckerError.new(nil)
      expect(error.message).to eq("No type Definition for: <> type")
    end

    it "handles empty string type correctly" do
      error = TypeCheckerError.new("")
      expect(error.message).to eq("No type Definition for: <> type")
    end
  end
end
