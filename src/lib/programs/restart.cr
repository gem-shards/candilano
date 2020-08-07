module Candilano
  module Programs
    class Restart
      property config : YAML::Any

      def initialize(config)
        @config = config
        @ssh = Candilano::Ssh.new(config["ssh"], config["servers"])
      end

      def run
        task_group = Task::Group.new("restart:app", "restart application", @config)
        task_group.tasks << Task.new(@config["restart_command"].to_s, user_env: false)
        task_group.execute(@ssh)
      end
    end
  end
end
