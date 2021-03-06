module Candilano
  module Programs
    class Init
      TEMPLATE = %<---
  app_name: 'your-app-name'
  repo_url: 'git@github:repo.git'
  deploy_to: '/location/to/deploy'
  branch: 'master'
  keep_releases: 5
  restart_command: 'service your-app-name restart'

  # Optionally, set a migrate command for database migrations
  # It will execute on the 'db' role only when it's present.
  # migrate_command: 'amber db migrate'

  ssh:
    user: user
    password: password
    port: 22
    key: '~/.ssh/id_rsa'
    forward_agent: true

  # linked_files:
  #   - 'config/settings.yml'

  # linked_directories:
  #  - 'log'
  #  - 'tmp'

  servers:
    - host: 127.0.0.1
      roles:
        - web
        - db
  # - host: 127.0.0.1
  #   roles:
  #     - web

  # hooks:
  #   before:
  #     - command: 'free'
  #       task_group: 'rollback:get_previous_version'
  #       target: 'remote'
  #       on_role: 'db'
  #   after:
  #     - command: 'free'
  #       task_group: 'rollback:get_previous_version'
  #       target: 'local'
      >

      def run
        Dir.mkdir("deploy") unless Dir.exists?("deploy")

        create_config("deploy/sandbox.yml")
        create_config("deploy/production.yml")
      end

      def create_config(path)
        File.write(path, TEMPLATE) unless File.exists?(path)
      end
    end
  end
end
