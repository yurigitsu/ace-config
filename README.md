# AceConfig

## Installation

Replace `ace-config` with your gem name right after releasing it to RubyGems.org. Please do not do it earlier due to security reasons. Alternatively, replace this section with instructions to install your gem from git if you don't plan to release to RubyGems.org.

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
  config custom_typed_opt_one: 42, type: Integer
end

MyApp.settings.option               # => 42
MyApp.settings.typed_opt_one        # => 42
MyApp.settings.typed_opt_two        # => 4.2
MyApp.settings.custom_typed_opt_one # => 42
```
## Gem Config Declaration

```ruby
require 'ace_config'

module MyGem
  extend AceDeck
end 

MyGem.configure :settings do
  config :option
  config.int :typed_opt_one
  config :typed_opt_two, type: :float
  config :custom_typed_opt_one, type: Integer
end

MyGem.settings.config declared_option: 1
MyGem.settings.config declared_typed_option: 1
MyGem.settings.config declared_custom_typed_option: 1
MyGem.settings.config declared_typed_option: '1'        # => raise AceConfigErr::SettingTypeError
MyGem.settings.config declared_custom_typed_option: '1' # => raise AceConfigErr::SettingTypeError
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
