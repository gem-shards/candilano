module Candilano
  module Programs
    class Deploy
      property config : YAML::Any
      property release_time : String

      def initialize(config)
        @release_time = generate_release_time
        @config = config
        @ssh = Candilano::Ssh.new(config["ssh"], config["servers"])
        @local = Candilano::Local.new
      end

      def generate_release_time
        time = Time.utc
        time.year.to_s + time.month.to_s + time.day.to_s + time.hour.to_s + time.minute.to_s + time.second.to_s
      end

      def run
        create_git_wrapper
        check_git_access
        create_default_folders
        clone_repo
        create_release
        symlink_directories
        symlink_files
        install_shards
        build_release
        remove_older_releases
        symlink_to_current
        restart_passenger
      end

      def create_git_wrapper
        task_group = Task::Group.new("deploy:git_wrapper", "create git wrapper", @config)
        task_group.tasks << Task.new("mkdir -p /tmp", false, false)
        task_group.tasks << Task.new("echo '#!/bin/sh -e\nexec /usr/bin/env ssh -o PasswordAuthentication=no -o StrictHostKeyChecking=no \\\"\\$@\\\"' > /tmp/git-ssh-wrapper.sh", false, false)
        task_group.tasks << Task.new("chmod 700 /tmp/git-ssh-wrapper.sh", false, false)
        task_group.execute(@ssh)
      end

      def check_git_access
        task_group = Task::Group.new("deploy:check_git_access", "check git acccess on remote", @config)
        task_group.tasks << Task.new("git ls-remote #{@config["repo_url"]} HEAD")
        task_group.execute(@ssh)
      end

      def create_default_folders
        task_group = Task::Group.new("deploy:create_default_folders", "check git acccess on remote", @config)
        task_group.tasks << Task.new("mkdir -p #{@config["deploy_to"]}/shared #{@config["deploy_to"]}/releases #{@config["deploy_to"]}/repo", false)
        task_group.execute(@ssh)
      end

      def clone_repo
        task_group = Task::Group.new("deploy:clone_and_prune_repo", "clone and prune repository", @config)
        if @ssh.file_exists?("#{@config["deploy_to"]}/repo/HEAD")
          task_group.tasks << Task.new("cd #{@config["deploy_to"]}/repo && ( export GIT_ASKPASS=\"/bin/echo\" GIT_SSH=\"/tmp/git-ssh-wrapper.sh\" ; /usr/bin/env git remote set-url origin #{@config["repo_url"]})", false)
        else
          task_group.tasks << Task.new("git clone --mirror #{@config["repo_url"]} #{@config["deploy_to"]}/repo")
        end
        task_group.tasks << Task.new("cd #{@config["deploy_to"]}/repo && ( export GIT_ASKPASS=\"/bin/echo\" GIT_SSH=\"/tmp/git-ssh-wrapper.sh\" ; /usr/bin/env git remote update --prune )", false)
        task_group.execute(@ssh)
      end

      def create_release
        task_group = Task::Group.new("deploy:create_release", "create and populate release", @config)
        task_group.tasks << Task.new("mkdir #{@config["deploy_to"]}/releases/#{release_time}")
        task_group.tasks << Task.new("cd #{@config["deploy_to"]}/repo && ( export GIT_ASKPASS=\"/bin/echo\" GIT_SSH=\"/tmp/git-ssh-wrapper.sh\" ; /usr/bin/env git archive master | /usr/bin/env tar -x -f - -C #{@config["deploy_to"]}/releases/#{release_time} )", false)
        task_group.tasks << Task.new("cd #{@config["deploy_to"]}/repo && ( export GIT_ASKPASS=\"/bin/echo\" GIT_SSH=\"/tmp/git-ssh-wrapper.sh\" ; /usr/bin/env git rev-list --max-count=1 master )", false)
        task_group.execute(@ssh)
      end

      def symlink_directories
        task_group = Task::Group.new("deploy:symlink_directories", "symlink directories", @config)
        @config["linked_directories"].as_a.map do |directory|
          task_group.tasks << Task.new("stat #{@config["deploy_to"]}/shared/#{directory} && rm -rf #{@config["deploy_to"]}/releases/#{release_time}/#{directory} && ln -s #{@config["deploy_to"]}/shared/#{directory} #{@config["deploy_to"]}/releases/#{release_time}/#{directory}", false, false)
        end
        task_group.execute(@ssh)
      end

      def symlink_files
        task_group = Task::Group.new("deploy:symlink_files", "symlink files", @config)
        @config["linked_files"].as_a.each do |file|
          task_group.tasks << Task.new("stat #{@config["deploy_to"]}/shared/#{file} && rm -rf #{@config["deploy_to"]}/releases/#{release_time}/#{file} && ln -s #{@config["deploy_to"]}/shared/#{file} #{@config["deploy_to"]}/releases/#{release_time}/#{file}", false, false)
        end
        task_group.execute(@ssh)
      end

      def install_shards
        task_group = Task::Group.new("deploy:install_shards", "create and populate release", @config)
        task_group.tasks << Task.new("cd #{@config["deploy_to"]}/releases/#{release_time} && shards -v --production", false)
        task_group.execute(@ssh)
      end

      def build_release
        task_group = Task::Group.new("deploy:build_release", "build release", @config)
        task_group.tasks << Task.new("cd #{@config["deploy_to"]}/releases/#{release_time} && shards build --production", false)
        task_group.execute(@ssh)
      end

      def remove_older_releases
        task_group = Task::Group.new("deploy:remove_older_releases", "remove older releases", @config)
        task_group.tasks << Task.new("cd #{@config["deploy_to"]}/releases && ls -A1t #{@config["deploy_to"]}/releases | tail -n +#{@config["keep_releases"]} | xargs rm -r", false)
        task_group.execute(@ssh)
      end

      def symlink_to_current
        task_group = Task::Group.new("deploy:symlink_to_current", "symlink release as current", @config)
        task_group.tasks << Task.new("rm #{@config["deploy_to"]}/current && ln -sf #{@config["deploy_to"]}/releases/#{release_time} #{@config["deploy_to"]}/current")
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
