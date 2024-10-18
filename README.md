# ace-config

Ruby gem created to simplify managing application configurations and enhance the development of other gems that require configuration management. It offers a simple interface for defining, setting, and retrieving configuration options with type validation, helping ensure configurations are correct and reliable.

- **ace-config** provides built-in support for importing and exporting configurations in JSON, YAML, and Hash formats, enhancing versatility. 

- **ace-config** offers various built-in types like basic types, data structures, numeric types, and time types.

- **ace-config** supports infinite nested configurations and 'classy' access providing a flexible and powerful configuration management solution.


## Features

- **Simple Configuration Management**: Easily define, set, and retrieve configuration options.
- **Type Validation**: Ensure configurations are correct with built-in type validation.
- **Multiple Formats**: Import and export configurations in JSON, YAML, and Hash formats.
- **Nested Configurations**: Support for infinite nested configurations for complex applications.
- **Classy Access**: Access configurations in a 'classy' manner for better organization and readability.
- **Built-in Types**: Utilize various built-in types including basic types, data structures, numeric types, and time types.
- **Extensible**: Easily extendable to accommodate custom configuration needs.

## Table of Contents
- [Installation](#installation)
- [Basic Usage](#basic-usage)
- [Configuration Container Usage](#configuration-container-usage)
- [Define with DSL Syntax](#define-with-dsl-syntax)
- Typing
  - [Configure Type Validation](#configure-type-validation)
  - [Define Configuration Type Validation](#define-configuration-type-validation)
  - [Type Schema](#type_schema)
  - [Built-in Types](#built-in-types)
- Import:
  - [Loading Configurations](#loading-configuration-data)
  - [Loading from a JSON String](#loading-from-a-json-string)
  - [Loading from a YAML File](#loading-from-a-yaml-file)
- Export:  
  - [Exporting Configurations](#exporting-configuration-data)
  - [to_h](#to_h)
  - [to_json](#to_json)
  - [to_yaml](#to_yaml)
- OSS
  - [Development](#development)
  - [Contributing](#contributing)
  - [License](#license)
  - [Code of Conduct](#code-of-conduct)

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
  include AceConfig
end 

MyApp.configure :settings do
  config option: 42
  config.int typed_opt_one: 42
  config typed_opt_two: 4.2, type: :float  
end

MyApp.settings.option                 # => 42
MyApp.settings.typed_opt_one          # => 42
MyApp.settings.typed_opt_two          # => 4.2
```

### Basic Syntax
```ruby
MyApp.configure :settings do
  config option: 42
end
```

## Namespacing
```ruby
MyApp.configure :app do
  configure :lvl_one do
    config opt: 100
    configure :lvl_two do
      config opt: 200
      configure :lvl_three do
        config opt: 300
        configure :lvl_four do
          config opt: 400
          configure :lvl_five do
            config opt: 500
            # NOTE: as deep as you want
          end
        end
      end
    end
  end
end

MyApp.app.lvl_one.opt                                     # => 100
MyApp.app.lvl_one.lvl_two.opt                             # => 200
MyApp.app.lvl_one.lvl_two.lvl_three.opt                   # => 300
MyApp.app.lvl_one.lvl_two.lvl_three.lvl_four.opt          # => 400
MyApp.app.lvl_one.lvl_two.lvl_three.lvl_four.lvl_five.opt # => 500
```

### Configure Type Validation
```ruby
MyApp.configure :settings do
  config custom_typed_opt_one: '42', type: :float
end
# => AceConfig::SettingTypeError
```

## Configuration Container Usage

```ruby
require 'ace_config'

module MyGem
  include AceConfig
end 
```

### Declare configurations
```ruby
MyGem.configure :settings do
  config :option
  config.int :typed_opt_one
  config :typed_opt_two, type: Integer
  # NOTE: declare nested namespace with configure <symbol arg>
  configure :nested do
    config :option
  end
end
```

### Define configurations
```ruby
MyGem.settings do 
  config option: 1
  config typed_opt_one: 2
  config typed_opt_two: 3 
  # NOTE: access namespace via <.dot_access> 
  config.nested do 
    config option: 4
  end
end
```

### Define with DSL Syntax
```ruby
MyGem.settings do 
  option 'one'
  typed_opt_one 1
  typed_opt_two 2 
  # NOTE: access namespace via <block> 
  nested do 
    option 'nested'
  end
end
```

### Get configurations
```ruby
MyGem.settings.option        # => 'one'
MyGem.settings.typed_opt_one # => 1
MyGem.settings.typed_opt_two # => 2
MyGem.settings.nested.option # => 'nested'
```

### Define Configuration Type Validation
```ruby
MyGem.settings do 
  config.typed_opt_two: '1'
end 
# => AceConfig::SettingTypeError

MyGem.settings do 
  typed_opt_two '1'
end 
# => AceConfig::SettingTypeError
```

### Union
```ruby
# List one of entries as built-in :symbols or classes

MyApp.configure :settings do
  config transaction_fee: 42, type: [Integer, :float, BigDecimal]
  config vendor_code: 42, type: [String, :int]
end 
```
### Custom
```ruby
MyApp.configure :settings do
  config option: CustomClass.new, type: CustomClass
end 
```
### Callable
```ruby
acc_proc = Proc.new { |val| val.respond_to?(:accounts) }
holder_lam = ->(name) { name.length > 5 }

MyApp.configure :settings do
  config acc_data: User.new, type: acc_proc
  config holder_name: 'John Doe', type: holder_lam
end 
```

## Loading Configuration Data

The `AceConfig` module allows you to load configuration data from various sources, including YAML and JSON. Below are the details for each option.

- `json` (String)
- `yaml` (String)
- `hash` (Hash)
- `schema` (Hash) (Optional) See: [Type Schema](#type_schema) and [Built-in Types](#built-in-types)

### Loading from a JSON String

You can load configuration data from a JSON string by passing the `json` option to the `configure` method.

#### Parameters

- `json` (String): A JSON string containing the configuration data.
- `schema` (Hash) (Optional): A hash representing the type schema for the configuration data.

#### Error Handling

- If the JSON format is invalid, a `LoadDataError` will be raised with the message "Invalid JSON format".

#### Example 1
```ruby
MyGem.configure(:settings, json: '{"opt_one":1,"opt_two":2}').settings
# => #<MyGem::Setting:0x00007f8c1c0b2a80 @options={:opt_one=>1, :opt_two=>2}>
```

#### Example 2
```ruby
MyGem.configure(:settings, json: '{"opt_one":1,"opt_two":2}', schema: { opt_one: :int, opt_two: :str })
# => AceConfig::SettingTypeError: Expected: <str>. Given: 2 which is <Integer> class.
```

#### Example 3
```ruby
MyGem.configure(:settings, json: '{"opt_one":1,"opt_two":2}', schema: { opt_one: :int, opt_two: :int })

MyGem.settings do 
  opt_one 1
  opt_two "2"
end
# => AceConfig::SettingTypeError: Expected: <intstr>. Given: \"2\" which is <String> class.
```

### Loading from a YAML File

You can also load configuration data from a YAML file by passing the `yaml` option to the `configure` method.

#### Parameters

- `yaml` (String): A file path to a YAML file containing the configuration data.
- `schema` (Hash) (Optional): A hash representing the type schema for the configuration data.

#### Error Handling

- If the specified YAML file is not found, a `LoadDataError` will be raised with the message "YAML file not found".

##### YAML File
```yaml
# settings.yml

opt_one: 1
opt_two: 2
```

#### Example 1
```ruby
MyGem.configure :settings, yaml: 'settings.yml' 
# => #<MyGem::Setting:0x00006f8c1c0b2a80 @options={:opt_one=>1, :opt_two=>2}>
```

#### Example 2
```ruby
MyGem.configure :settings, yaml: 'settings.yml', schema: { opt_one: :int, opt_two: :str }
# => AceConfig::SettingTypeError: Expected: <str>. Given: 2 which is <Integer> class.
```

#### Example 3
```ruby
MyGem.configure :settings, yaml: 'settings.yml', schema: { opt_one: :int, opt_two: :int }

MyGem.settings do 
  opt_one 1
  opt_two "2"
end
# => AceConfig::SettingTypeError: Expected: <intstr>. Given: \"2\" which is <String> class.
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

### type_schema
```ruby
MyGem.configure :settings do
  config.int opt_one: 1
  config.str opt_two: "2"
end

MyGem.settings.type_schema # => {:opt_one=>:int, :opt_two=>:str}
```

## Built-in Types Features

### Base Types
```ruby
:int  => Integer
:str  => String
:sym  => Symbol
:null => NilClass
:any  => Object
:true_class  => TrueClass
:false_class => FalseClass
```

### Data Structures
```ruby 
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
