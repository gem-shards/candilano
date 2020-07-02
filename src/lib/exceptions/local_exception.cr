class LocalException < Exception
  def initialize(error)
    print "ERROR: #{error}}\n".colorize(:red)
    exit
  end
end
