module Candilano
  class Task
    class Group
      property tasks : Array(Task)
      property description : String
      property identifier : String

      def initialize(identifier : String, description : String, config : YAML::Any)
        @tasks = Array(Task).new
        @description = description
        @identifier = identifier
        @config = config
      end

      def add(task : Task)
        tasks << task
      end

      def execute(ssh, local = false)
        print "#{@identifier} - #{@description}\n".colorize(:light_blue)

        call_hook("before", ssh, local)

        tasks.each do |task|
          task.execute(ssh)
        end

        call_hook("after", ssh, local)
      end

      def execute_local(local)
        print "#{@identifier} - #{@description}\n".colorize(:light_blue)
        tasks.each do |task|
          task.execute_local(local)
        end
      end

      def call_hook(action, ssh, local)
        return unless @config["hooks"]?

        @config["hooks"][action].as_a.each do |hook|
          if hook["task_group"].to_s == @identifier
            task = Task.new(hook["command"].to_s, user_env: false, dry_run: false, on_role: hook["on_role"]?)
            if hook["target"].to_s == "remote"
              task.execute(ssh)
            else
              task.execute_local(ssh)
            end
          end
        end
      end
    end
  end
end
