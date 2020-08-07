require "./task/*"

module Candilano
  class Task
    property command : String
    property role : String | Nil
    property user_env : Bool
    property dry_run : Bool

    def initialize(command, @user_env = true, @dry_run = false, @role = nil)
      @command = command
    end

    def execute(ssh)
      print "   " + @command.gsub("\n", "").colorize(:yellow).to_s + "\n"
      ssh.execute(command, user_env: @user_env, dry_run: @dry_run, role: @role)
    end

    def execute_local(local)
      print ("   LOCAL: " + @command.gsub("\n", "")).colorize(:yellow).to_s + "\n"
      local.execute(command, dry_run: @dry_run)
    end
  end
end
