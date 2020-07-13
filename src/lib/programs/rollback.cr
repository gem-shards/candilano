module Candilano
  module Programs
    class Rollback
      property config : YAML::Any

      def initialize(config)
        @config = config
        @ssh = Candilano::Ssh.new(config["ssh"], config["servers"])
        @local = Candilano::Local.new
      end

      def run
        replace_current
        restart_app
        cleanup_rollback
      end

      def replace_current
        task_group = Task::Group.new("rollback:replace_current", "replace current with previous release", @config)
        task_group.tasks << Task.new("cd #{@config["deploy_to"]} && rm -f current && ln -s releases/\\\`ls -A1t #{@config["deploy_to"]}/releases/ | head -2 | tail -n 1\\\` current", false, false)
        task_group.execute(@ssh)
      end

      def restart_app
        task_group = Task::Group.new("deploy:restart_passenger", "restart passenger", @config)
        task_group.tasks << Task.new("passenger-config restart-app #{@config["deploy_to"]}/current/public --ignore-app-not-running", false)
        task_group.execute(@ssh)
      end

      def cleanup_rollback
        task_group = Task::Group.new("rollback:cleaup_rollback", "clean up previous release", @config)
        task_group.tasks << Task.new("cd #{@config["deploy_to"]} && tar -czf rolled-back-release-\\\`ls -A1t releases/ | head -1\\\`.tar.gz releases/\\\`ls -A1t releases/ | head -1\\\`", false, false)
        task_group.tasks << Task.new("cd #{@config["deploy_to"]} && rm -rf releases/\\\`ls -A1t releases/ | head -1\\\`", false, false)
        task_group.execute(@ssh)
      end
    end
  end
end
