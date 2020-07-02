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
        get_previous_version
        # replace_current
        # restart_passenger
      end

      def get_previous_version
        task_group = Task::Group.new("rollback:get_previous_version", "get previous version", @config)
        task_group.tasks << Task.new("ls -A #{@config["deploy_to"]}/releases | tail -n 2 | head -1", false, false)
        task_group.execute(@ssh)
      end

      def restart_passenger
        task_group = Task::Group.new("deploy:restart_passenger", "restart passenger", @config)
        task_group.tasks << Task.new("passenger-config restart-app #{@config["deploy_to"]}/current/public --ignore-app-not-running", false)
        task_group.execute(@ssh)
      end
    end
  end
end
