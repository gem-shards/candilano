module Candilano
  module Programs
    class Check
      property config : YAML::Any

      def initialize(config)
        @config = config
        @ssh = Candilano::Ssh.new(config["ssh"], config["servers"])
        @local = Candilano::Local.new
      end

      def run
        git_wrapper
        git_check
        check_directories
        check_files
      end

      def git_wrapper
        task_group = Task::Group.new("check:git_wrapper", "create git wrapper", @config)
        task_group.tasks << Task.new("mkdir -p /tmp", false, false)
        task_group.tasks << Task.new("echo '#!/bin/sh -e\nexec /usr/bin/env ssh -o PasswordAuthentication=no -o StrictHostKeyChecking=no \\\"\\$@\\\"' > /tmp/git-ssh-wrapper.sh", false, false)
        task_group.tasks << Task.new("chmod 700 /tmp/git-ssh-wrapper.sh", false, false)
        task_group.execute(@ssh)
      end

      def git_check
        task_group = Task::Group.new("check:git_check", "check git", @config)
        task_group.tasks << Task.new("git ls-remote #{@config["repo_url"]} HEAD")
        task_group.execute(@ssh)
      end

      def check_directories
        return unless @config["linked_directories"]?

        task_group = Task::Group.new("check:directories", "check/create symlinked directories", @config)

        dirs = @config["linked_directories"].as_a.map do |directory|
          "#{@config["deploy_to"]}/shared/#{directory}"
        end

        task_group.tasks << Task.new("mkdir -p #{dirs.join(" ")}", false, false)
        task_group.execute(@ssh)
      end

      def check_files
        return unless @config["linked_files"]?

        task_group = Task::Group.new("check:files", "check presence of symlinked files", @config)
        @config["linked_files"].as_a.each do |file|
          task_group.tasks << Task.new("stat #{@config["deploy_to"]}/shared/#{file}", false, false)
        end
        task_group.execute(@ssh)
      end
    end
  end
end
