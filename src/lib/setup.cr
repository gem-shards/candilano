require "./exceptions/*"
require "./programs/*"

module Candilano
  class Setup
    property command : String
    property environment : String

    def initialize(command : String, environment : String)
      @command = command
      @environment = environment
    end

    def load_config
      File.open("deploy/#{@environment}.yml") do |file|
        YAML.parse(file)
      end
    rescue
      raise LocalException.new("Failed to open config file: deploy/#{@environment}.yml")
    end

    def execute
      release = case @command
                when "check"
                  load_config
                  Programs::Check.new(load_config)
                when "deploy"
                  Programs::Deploy.new(load_config)
                when "rollback"
                  Programs::Rollback.new(load_config)
                when "restart"
                  Programs::Restart.new(load_config)
                when "init"
                  Programs::Init.new
                else
                  Programs::Check.new(load_config)
                end
      release.run
      print "All done.".colorize(:light_magenta)
    end
  end
end
