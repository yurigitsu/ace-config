# frozen_string_literal: true

module YamlHelper
  def yaml_helper_tempfile
    Tempfile.create(["config", ".yml"]) do |temp_file|
      temp_file.write({ username: "admin", max_connections: 10 }.to_yaml)
      temp_file.rewind

      yield temp_file
    end
  end
end
