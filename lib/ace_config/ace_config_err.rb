# frozen_string_literal: true

module AceConfigErr
  # Custom error raised when a setting type does not match the expected type.
  #
  # @example Raising an AceConfigErr::SettingTypeError
  #   raise AceConfigErr::SettingTypeError.new(:int, "string")
  #   # => raises AceConfigErr::SettingTypeError with message
  #   # "Expected: <int>. Given: \"string\" which is <String> class."
  class SettingTypeError < TypeError
    # Initializes a new AceConfigErr::SettingTypeError.
    #
    # @param type [Symbol] The expected type.
    # @param val [Object] The value that was provided.
    def initialize(type, val)
      super(type_error_msg(type, val))
    end

    # Generates the error message for the exception.
    #
    # @param type [Symbol] The expected type.
    # @param val [Object] The value that was provided.
    # @return [String] The formatted error message.
    def type_error_msg(type, val)
      "Expected: <#{type}>. Given: #{val.inspect} which is <#{val.class}> class."
    end
  end

  # Custom error raised when a type definition is missing.
  #
  # @example Raising an AceConfigErr::TypeCheckerError
  #   raise AceConfigErr::TypeCheckerError.new(:unknown_type)
  #   # => raises AceConfigErr::TypeCheckerError with message "No type Definition for: <unknown_type> type"
  class TypeCheckerError < StandardError
    # Initializes a new AceConfigErr::TypeCheckerError.
    #
    # @param type [Symbol] The type that is missing a definition.
    def initialize(type)
      super(definition_error_msg(type))
    end

    # Generates the error message for the exception.
    #
    # @param type [Symbol] The type that is missing a definition.
    # @return [String] The formatted error message.
    def definition_error_msg(type)
      "No type Definition for: <#{type}> type"
    end
  end

  # Custom error raised when data loading fails.
  class LoadDataError < StandardError; end
end
