module Candilano
  module Programs
    class Init
      TEMPLATE = %<---
  app_name: 'your-app-name'
  repo_url: 'git@github:repo.git'
  deploy_to: '/location/to/deploy'
  keep_releases: 5
  restart_command: 'service your-app-name restart'

  # linked_files:
  #   - 'config/settings.yml'

  # linked_directories:
  #  - 'log'
  #  - 'tmp'

  ssh:
    user: user
    password: password
    port: 22
    key: '~/.ssh/id_rsa'
    forward_agent: true

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
  #   after:
  #     - command: 'free'
  #       task_group: 'rollback:get_previous_version'
  #       target: 'local'
      >

      def initialize
      end

      def run
        Dir.mkdir("deploy") unless Dir.exists?("deploy")
        File.write("deploy/sandbox.yml", TEMPLATE) unless File.exists?("deploy/sandbox.yml")
        File.write("deploy/production.yml", TEMPLATE) unless File.exists?("deploy/production.yml")
      end
    end
  end
end
