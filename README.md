## Capistrano::Systemd

## Installation

Add this line to your application's Gemfile:

```ruby
group :development do
  gem 'capistrano-systemd', github: 'netrusov/capistrano-systemd'
end
```

And then execute:
```
bundle install
```

Let Capistrano know about this plugin by adding the following lines to the `Capfile`:

```ruby
require 'capistrano/systemd'

install_plugin Capistrano::Systemd
```
