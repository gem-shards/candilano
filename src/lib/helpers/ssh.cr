module Candilano
  class Ssh
    property user : String
    property servers : YAML::Any
    property port : Int32
    property key : String

    def initialize(config : YAML::Any, servers : YAML::Any)
      @user = config["user"].to_s
      @servers = servers
      @port = config["port"].to_s.to_i32
      @key = config["key"].to_s
      @forward_agent = config["forward_agent"].to_s == "true" ? true : false
    end

    def execute(command : String, user_env = true, dry_run = false, on_role = nil)
      channel = Channel(Hash(String, String)).new
      executed_size = 0

      servers.as_a.each do |server|
        if on_role
          next unless server["roles"].as_a.includes?(on_role)
        end
        spawn do
          channel.send(run_command(server["host"], command, user_env, dry_run))
        end
        executed_size += 1
      end

      results = Array(Hash(String, String)).new
      until results.size == executed_size
        results << channel.receive
      end

      results.each do |result|
        raise RemoteException.new(result) if result["error"] != ""
        print "   ✔ #{@user}@#{result["host"]}".colorize(:green).to_s + " #{result["elapsed_time"]}s\n"
      end

      results
    end

    def run_command(host, command, user_env, dry_run = false)
      comm = prepare_command(command, user_env)
      output = IO::Memory.new
      error = IO::Memory.new
      elapsed_time = Time.measure do
        unless dry_run
          Process.run("sh", {"-c", "#{build_command(host)} #{comm}"}, output: output, shell: true, error: error)
        end
      end

      # Raise exception when error
      error.close

      # Output result
      output.close

      {"host"         => host.to_s,
       "error"        => error.to_s.strip,
       "output"       => output.to_s.strip,
       "elapsed_time" => elapsed_time.total_seconds.round(3).to_s}
    end

    def prepare_command(command, user_env)
      if user_env
        "\"/usr/bin/env #{command}\""
      else
        "\"#{command}\""
      end
    end

    def build_command(host)
      str = "ssh"
      str += " #{@user}@#{host}"
      str += " -o ConnectTimeout=3"
      str += " -A" if @forward_agent
      str += " -i #{@key}" if @key
      str += " -p #{@port}" if @port
      str
    end

    def file_exists?(path)
      results = execute("test -f #{path} && echo \"true\"", false, false)
      does_exists = true
      results.each do |result|
        does_exists = false if result["output"] != "true"
      end

      does_exists
    end

    # TODO: SCP files from local to remote
    def scp(local_file : String, remote_file : String)
    end
  end
end
