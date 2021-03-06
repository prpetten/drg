# DRG [![Code Climate](https://codeclimate.com/github/ridiculous/drg/badges/gpa.svg)](https://codeclimate.com/github/ridiculous/drg) [![Gem Version](https://badge.fury.io/rb/drg.svg)](http://badge.fury.io/rb/drg) [![Build Status](https://travis-ci.org/ridiculous/drg.svg)](https://travis-ci.org/ridiculous/drg)


A Ruby utility to help automate dependency management using Bundler. You can pin Gem versions to the current or the next
available level.

## Requirements

* Bundler 1.10+

## Installation

```ruby
gem 'drg'
```

## Tasks

```bash
% rake -T
rake drg:pin                    # Pin the gems in your Gemfile to the current version in the Gemfile.lock
rake drg:pin:major              # Add the approximate major version of your gems (rails, "~> 4")
rake drg:pin:minor              # Add the approximate minor version of your gems (rails, "~> 4.2")
rake drg:pin:patch              # Add the approximate patch version of your gems (rails, "~> 4.2.3")
rake drg:pin:latest[gem]        # Pin the given gem to the latest version (defaults to all gems)
rake drg:pin:minor_latest[gem]  # Pin the given gem to the latest available patch version (defaults to all gems)
rake drg:pin:patch_latest[gem]  # Pin the given gem to the latest available minor version (defaults to all gems)
rake drg:unpin                  # Unpin the gems in your Gemfile
```

### drg:pin

DRG really wants to help you manage your project's gems. But DRG doesn't want to replace Bundler. Instead, we want to build on
it. Pinning ignores gems that are fetched from somewhere other than rubygems. For example, gems listed with `:git`, `:github`,
or `:path` will be ignored. You can "pin" all your versions to the current version listed in the Gemfile.lock:

```bash
rake drg:pin
```

This task will update your Gemfile with the gem's approximate version. It'll change:

```ruby
gem 'rails'
gem 'byebug', require: false
gem 'therubyracer', '~> 0.12', platforms: :ruby
gem 'drg' # :)
```

to:

```ruby
gem 'rails', '~> 4.2'
gem 'byebug', '~> 5.0', require: false
gem 'therubyracer', '~> 0.12', platforms: :ruby
gem 'drg', '~> 1.2' # :)
```

### Automation

I use the [bin/drg](https://github.com/ridiculous/drg/blob/master/bin/drg) bash script to update all gems to the latest 
[major|minor|patch] version, run all tests and then add the result if the specs pass or rollback the changes if they 
fail (e.g. `bin/drg patch`). 

### Skipping gems

You can tell drg to ignore gems by adding an inline comment with @drg (skip|ignore|frozen)

```ruby
gem 'name' # @drg skip
```

## Changes

Looking for `drg:spec` that does RSpec scaffolding? It's been moved to it's own gem: [rspec-scaffold](https://github.com/ridiculous/rspec-scaffold)  

## Issues

Having trouble on Rails 3? Try updating to the latest version or make sure the
line with `gem 'drg'` is outside of the `:development` and `:test` blocks. It
Needs to be at the top level for some reason.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake` to run the tests. 
You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ridiculous/drg.
