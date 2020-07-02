class RemoteException < Exception
  def initialize(result)
    print "ERROR: #{result["host"]} - #{result["error"]}\n".colorize(:red)
    exit
  end
end
