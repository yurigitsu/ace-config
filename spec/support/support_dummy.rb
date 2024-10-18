# frozen_string_literal: true

# Dummy module provides utility methods for creating dummy classes and modules
# for testing purposes with AceConfiguration.
module Dummy
  # Creates a dummy class with the specified name and extends it with
  # AceConfiguration::Isolated.
  #
  # @param name [String] The name of the class to be created.
  # @example Creating a dummy class
  #   support_dummy_class("TestClass")
  #   expect(TestClass).to be_a(Class)
  def support_dummy_class(name)
    stub_const(name, Class.new { extend AceConfiguration::Local })
  end

  # Creates a base configuration class named "BaseConfig" and includes
  # AceConfiguration::Isolated.
  #
  # @example Creating a base configuration class
  #   suppoert_dummy_base_config
  #   expect(BaseConfig).to be_a(Class)
  def suppoert_dummy_instance_settings
    stub_const("InstanceSettings", Class.new do
      include AceConfiguration

      configure :settings
    end)
  end

  # Creates a dummy module that extends AceConfiguration.
  #
  # @return [Module] A new module that extends AceConfiguration.
  # @example Creating a dummy module
  #   dummy_module = support_dummy_module
  #   expect(dummy_module).to respond_to(:configure)
  def support_dummy_module
    Module.new { extend AceConfiguration }
  end
end
