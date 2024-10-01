# frozen_string_literal: true

# AceConfig module provides functionality for managing configuration features.
#
# @example Using AceConfiguration in a class
#   class MyApp
#     include AceConfiguration
#
#     configure :settings do
#       config api_key: "default_key"
#       config max_retries: 3
#     end
#   end
#
#   MyApp.settings.api_key # => "default_key"
#   MyApp.settings.max_retries # => 3
module AceConfiguration
  # Extends the base class with AceConfig::Configuration module methods
  #
  # @param base [Class] The class including this module
  def self.included(base)
    base.extend(AceConfig::Configuration)
  end

  # Isolated module handles isolated configurations.
  #
  # This module allows for configuration inheritance while maintaining
  # isolation between parent and child configurations.
  #
  # @example Using Isolated configurations
  #   class ParentApp
  #     include AceConfiguration::Isolated
  #
  #     configure :parent_settings do
  #       config timeout: 30
  #       config tries: 3
  #     end
  #   end
  #
  #   class ChildApp < ParentApp
  #     parent_settings do
  #       config tries: 4
  #     end
  #   end
  #
  #   ChildApp.parent_settings.timeout # => 30
  #   ChildApp.parent_settings.tries # => 4
  #   ParentApp.parent_settings.tries # => 3
  module Isolated
    # Extends the base class with AceConfig::Configuration and AceConfig::Configuration::Isolated module methods
    #
    # @param base [Class] The class including this module
    def self.included(base)
      base.extend(AceConfig::Configuration)
      base.extend(AceConfig::Configuration::Isolated)
    end
  end
end
