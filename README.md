# ace-config



**ace-config** is a Ruby gem created to simplify managing application configurations and enhance the development of other gems that require configuration management. It offers a simple interface for defining, setting, and retrieving configuration options with type validation, helping ensure configurations are correct and reliable.

**ace-config** provides built-in support for importing and exporting configurations in JSON, YAML, and Hash formats, enhancing versatility. 

**ace-config** offers various built-in types like basic types, data structures, numeric types, and time types.

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
end

MyApp.settings.option               # => 42
MyApp.settings.typed_opt_one        # => 42
MyApp.settings.typed_opt_two        # => 4.2
```

### Type validation
```ruby
MyApp.configure :settings do
  config custom_typed_opt_one: '42', type: :float
end
# => AceConfigErr::SettingTypeError
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
end
```

### Set configurations
```ruby
MyGem.settings do 
  config.option: 1
  config.typed_opt_one: 1
  config.typed_opt_two: 1 
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
# => AceConfigErr::SettingTypeError
```

### to_h
```ruby
MyGem.settings.to_h # => { option: 1, typed_opt_one: 1, typed_opt_two: 1 }
```

### to_json
```ruby
MyGem.settings.to_json # => "{\"option\":1,\"typed_opt_one\":1,\"typed_opt_two\":1}"
```

### to_yaml
```ruby
MyGem.settings.to_yaml # => "---\noption: 1\ntyped_opt_one: 1\ntyped_opt_two: 1\n"
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
