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

## Prerequisites

You must enable [lingering](https://www.freedesktop.org/software/systemd/man/loginctl.html#enable-linger%20USER%E2%80%A6) on all target hosts:

```shell script
sudo loginctl enable-linger <USER>
```

## Configuration

See [set_defaults](lib/capistrano/systemd.rb) for default configuration options.

If you want to create your own Systemd units, then place them in any directory inside your repo, change `systemd_templates_path` setting, and specify roles for those units:

```ruby
set :systemd_templates_path, -> { 'path/to/your/directory' }
set :systemd_roles, -> do
  {
    puma: fetch(:puma_role),
    sidekiq: fetch(:puma_role),
    your_unit: fetch(:your_unit_role) # it's an example; you must use a real name, obviously
  }
end
```

Be sure to add `.erb` extension for each file, otherwise `capistrano-systemd` won't find them.

## Usage

```shell script
cap <stage> systemd:<task>
```

List of available tasks:

```
export
enable
disable
start
stop
restart
reload
status
```

You can pass service names as a `rake` task arguments - inside square brackets, separated by comma.
If service name is not passed, then it will run command against the main application service.
`export` is a special command for uploading service unit configuration files to the target host and it doesn't accept arguments.

Examples:

```shell script
cap <stage> systemd:export
cap <stage> systemd:enable[puma,puma@3000,sidekiq,sidekiq@1]
cap <stage> systemd:start
cap <stage> systemd:restart[sidekiq]
cap <stage> systemd:reload[puma@*]
cap <stage> systemd:status
cap <stage> systemd:stop
cap <stage> systemd:disable
```

You can also use [bash's native shell expansion](https://www.gnu.org/software/bash/manual/html_node/Shell-Expansions.html) on the target host, but be sure to enclose the whole command into quotes:

```shell script
cap <stage> "systemd:start[sidekiq@{1\,2}]"

# this will produce the following command
# => systemctl --user start sidekiq@1 sidekiq@2
```

Also note that comma is escaped. That's because `rake` tasks use it as an argument list separator and without escape it will be expanded into:

```shell script
systemctl --user start "sidekiq@{1" "2}"
```

Use `..` expansion for numbers where possible:

```shell script
cap <stage> "systemd:start[sidekiq@{1..2},puma@{3000..3002}]"

# this will produce the following command
# => systemctl --user start sidekiq@1 sidekiq@2 puma@3000 puma@3001 puma@3002
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/netrusov/capistrano-systemd.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
