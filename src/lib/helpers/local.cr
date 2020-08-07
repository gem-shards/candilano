module Candilano
  class Local
    def initialize
    end

    def execute(command : String, dry_run = false)
      output = IO::Memory.new
      return if dry

      elapsed_time = Time.measure do
        Process.run("sh", {"-c", "#{command}"}, output: output, shell: true)
      end
      print "   ✔ localhost".colorize(:green).to_s + " #{elapsed_time.total_seconds.round(3)}s\n"

      output.close
      output.to_s
    end
  end
end
