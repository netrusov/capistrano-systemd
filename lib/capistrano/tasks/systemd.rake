# frozen_string_literal: true

# for some reason capistrano doesn't see methods without this hack
this = self

namespace :systemd do
  %w[start stop restart reload enable disable].each do |action|
    desc "#{action.capitalize} systemd service"
    task action do |task, args|
      task.reenable

      services = args.to_a
      services << fetch(:systemd_application) if services.empty? || action == 'enable'

      services.uniq.map { |service| service.split('@') }.each do |service, formation|
        on roles(this.systemd_service_role(service)) do
          if formation
            execute :systemctl, '--user', action, [service, formation].join('@')
          else
            execute :systemctl, '--user', action, service
          end
        end
      end
    end
  end

  desc 'Show systemd service status'
  task :status do |task, args|
    on roles(:all) do
      task.reenable

      begin
        execute :systemctl, '--user', :status, *args.to_a
      rescue SSHKit::Command::Failed
        # Ignore this because `systemctl` returns non-zero values for stopped and absent services
      end
    end
  end

  desc 'Reload systemd manager configuration'
  task 'daemon-reload' do
    on roles(:all) do
      execute :systemctl, '--user', 'daemon-reload'
    end
  end

  desc 'Export systemd configuration files'
  task :export do
    on roles(:all) do
      home_dir = capture :pwd
      systemd_unit_path = File.join(home_dir, '.config', 'systemd', 'user')

      execute :mkdir, '-p', systemd_unit_path

      within systemd_unit_path do
        templates = Dir.glob(File.join(fetch(:systemd_templates_path), '**', '*.erb'))

        templates.each do |template|
          filename = File.basename(template, '.erb')
          contents = ERB.new(File.read(template), nil, '-').result(binding)

          upload! StringIO.new(contents), filename
        end

        # Upload master service
        upload! StringIO.new(<<-TEXT.gsub(/^ +/, '')), fetch(:systemd_master_service)
          [Service]
          Type=oneshot
          ExecStart=/bin/true
          RemainAfterExit=yes

          [Install]
          WantedBy=default.target
        TEXT
      end
    end
  end
end
