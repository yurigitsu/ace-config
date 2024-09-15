# ace-config



**ace-config** is a Ruby gem created to simplify managing application configurations and enhance the development of other gems that require configuration management. It offers a simple interface for defining, setting, and retrieving configuration options with type validation, helping ensure configurations are correct and reliable.

**ace-config** provides built-in support for importing and exporting configurations in JSON, YAML, and Hash formats, enhancing versatility. 

**ace-config** offers various built-in types like basic types, data structures, numeric types, and time types.

**ace-config** supports infinite nested configurations and 'classy' access providing a flexible and powerful configuration management solution.

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add ace-config
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install ace-config
```

## Basic Usage

```ruby
require 'ace_config'

module MyApp
  extend AceDeck
end 

MyApp.configure :settings do
  config option: 42
  config.int typed_opt_one: 42
  config typed_opt_two: 4.2, type: :float  
  configure :nested do
    config opt: 42
    configure :deep_nested do
      config opt: 42
    end
  end
end

MyApp.settings.option                 # => 42
MyApp.settings.typed_opt_one          # => 42
MyApp.settings.typed_opt_two          # => 4.2
MyApp.settings.nested.opt             # => 42
MyApp.settings.nested.deep_nested.opt # => 42
```

### Type validation
```ruby
MyApp.configure :settings do
  config custom_typed_opt_one: '42', type: :float
end
# => AceConfig::SettingTypeError
```

## Gem Configurations Usage

```ruby
require 'ace_config'

module MyGem
  extend AceDeck
end 
```

### Declare configurations
```ruby
MyGem.configure :settings do
  config :option
  config.int :typed_opt_one
  config :typed_opt_two, type: Integer
  # NOTE: declare nested namespace with <symbol arg>
  configure :nested do
    config :option
  end
end
```

### Set configurations
```ruby
MyGem.settings do 
  config option: 1
  config typed_opt_one: 1
  config typed_opt_two: 1 
  # NOTE: access namespace for set via <.dot_access> 
  config.nested do 
    config option: 1
  end
end
```

### Get configurations
```ruby
MyGem.settings.option        # => 1
MyGem.settings.typed_opt_one # => 1
MyGem.settings.typed_opt_two # => 1
```

### Type validation
```ruby
MyGem.settings do 
  config.typed_opt_two: '1'
end 
# => AceConfig::SettingTypeError
```

## Loading Configuration Data

The `AceConfig` module allows you to load configuration data from various sources, including YAML and JSON. Below are the details for each option.

### Loading from a JSON String

You can load configuration data from a JSON string by passing the `json` option to the `configure` method.

#### Parameters

- `json` (String): A JSON string containing the configuration data.

#### Error Handling

- If the JSON format is invalid, a `LoadDataError` will be raised with the message "Invalid JSON format".

#### Example
```ruby
MyGem.configure(:settings, json: '{"opt_one":1,"opt_two":2}')
# => #<MyGem::Setting:0x00007f8c1c0b2a80 @options={:opt_one=>1, :opt_two=>2}>
```

### Loading from a YAML File

You can also load configuration data from a YAML file by passing the `yaml` option to the `configure` method.

#### Parameters

- `yaml` (String): A file path to a YAML file containing the configuration data.

#### Error Handling

- If the specified YAML file is not found, a `LoadDataError` will be raised with the message "YAML file not found".

#### Example
```ruby
MyGem.configure :settings, yaml: 'config/settings.yml' 
# => #<MyGem::Setting:0x00006f8c1c0b2a80 @options={:opt_one=>1, :opt_two=>2}>
```

## Exporting Configuration Data

You can dump the configuration data in various formats using the following methods:

### to_h
```ruby
MyGem.configure :settings do
  config opt_one: 1
  config opt_two: 2
end

MyGem.settings.to_json # => '{"opt_one":1,"opt_two":2}'
```

### to_json
```ruby
MyGem.configure :settings do
  config opt_one: 1
  config opt_two: 2
end

MyGem.settings.to_json # => '{"opt_one":1,"opt_two":2}'
```

### to_yaml
```ruby
MyGem.configure :settings do
  config opt_one: 1
  config opt_two: 2
end

MyGem.settings.to_yaml # => "---\nopt_one: 1\nopt_two: 2\n"
``` 


## Built-in Types

```ruby
# Base Types
:int  => Integer
:str  => String
:sym  => Symbol
:null => NilClass
:any  => Object
:true_class  => TrueClass
:false_class => FalseClass

# Data Structures
:hash  => Hash
:array => Array
```
### Numeric
```ruby
:big_decimal => BigDecimal,
:float       => Float,
:complex     => Complex,
:rational    => Rational,
```
### Time 
```ruby
:date      => Date,
:date_time => DateTime,
:time      => Time,
```
### Composite
```ruby
:bool       => [TrueClass, FalseClass],
:numeric    => [Integer, Float, BigDecimal],
:kernel_num => [Integer, Float, BigDecimal, Complex, Rational],
:chrono     => [Date, DateTime, Time]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yurigitsu/ace-config. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/yurigitsu/ace-config/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the AceConfig project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/yurigitsu/ace-config/blob/main/CODE_OF_CONDUCT.md).
