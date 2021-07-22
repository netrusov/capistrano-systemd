# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name = 'capistrano-systemd'
  spec.version = '0.0.1'
  spec.authors = ['Alexander Netrusov']
  spec.license = 'MIT'

  spec.summary = 'Capistrano <3 systemd'

  spec.files = Dir['LICENSE', 'lib/**/*']
  spec.extra_rdoc_files = ['README.md']

  spec.require_path = 'lib'

  spec.required_ruby_version = '>= 2.4.0'

  spec.add_dependency 'capistrano', '~> 3.7'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rubocop'
end
