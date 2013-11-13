require 'remote_syslog/logger'

require 'socket'
require 'thread'

class SyslogDaemon
  attr_reader :port

  def initialize(port)
    @port = port
    @queue = Queue.new
    @server = TCPServer.new(port)
    @thread = Thread.new do
      client = @server.accept
      @queue << client.gets
      client.close
    end
  end

  def address
    "localhost:#{port}"
  end

  def messages
    [[:info, @queue.pop]]
  end
end

describe RemoteSyslog::Logger do
  let(:port) { 2323 }

  it "sends messages to a remote syslog daemon" do
    syslog = SyslogDaemon.new(port)

    logger = RemoteSyslog::Logger.new(syslog.address)
    logger.info "TESTING 1-2-3"

    syslog.messages.should == [[:info, "TESTING 1-2-3"]]
  end
end
