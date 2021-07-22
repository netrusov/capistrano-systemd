# frozen_string_literal: true

require 'capistrano/plugin'

module Capistrano
  class Systemd < Capistrano::Plugin
    def set_defaults
      set :systemd_application, -> { fetch(:application).downcase }
      set :systemd_master_service, -> { [fetch(:systemd_application), 'service'].join('.') }
      set :systemd_templates_path, -> { File.expand_path('templates/systemd', __dir__) }

      # Example:
      #   set :systemd_roles, -> do
      #     {
      #       puma: fetch(:puma_role),
      #       sidekiq: fetch(:sidekiq_role)
      #     }
      #   end
      set :systemd_roles, -> { {} }
    end

    def register_hooks
      after 'deploy:starting', 'systemd:export'
      after 'systemd:export', 'systemd:daemon-reload'
    end

    def define_tasks
      eval_rakefile File.expand_path('tasks/systemd.rake', __dir__)
    end

    def systemd_service_role(service)
      fetch(:systemd_roles, {}).fetch(service.to_sym, :all)
    end
  end
end
