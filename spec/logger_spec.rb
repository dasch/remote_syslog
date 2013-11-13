require 'remote_syslog/logger'

require 'socket'
require 'thread'

class SyslogDaemon
  attr_reader :port

  def initialize(port)
    @port = port
    @queue = Queue.new
    @server = TCPServer.new(port)
    @messages = []
    @thread = Thread.new do
      loop do
        client = @server.accept
        while message = client.gets
          @queue << message
        end
      end
    end
  end

  def address
    "localhost:#{port}"
  end

  def messages
    read_messages!
    @messages
  end

  private

  def read_messages!
    loop do
      sleep 0.01
      break if @queue.empty?
      packet = SyslogProtocol.parse(@queue.pop)
      @messages << [packet.severity_name, packet.content]
    end
  end
end

describe RemoteSyslog::Logger do
  let(:port) { 2323 }
  let(:syslog) { SyslogDaemon.new(port) }
  let(:logger) { RemoteSyslog::Logger.new(syslog.address) }

  it "sends messages to a remote syslog daemon" do
    logger.info "TESTING 1-2-3"

    syslog.messages.should == [["info", "TESTING 1-2-3"]]
  end

  it "supports all the log levels" do
    logger.debug("I like big butts")
    logger.info("And I cannot lie")
    logger.warn("You other brothers can't deny")
    logger.error("That when a girl walks in with an itty bitty waist")
    logger.fatal("And a round thing in your face")
    logger.unknown("You get sprung, wanna pull out your tough")

    syslog.messages.should == [
      ["debug", "I like big butts"],
      ["info", "And I cannot lie"],
      ["warn", "You other brothers can't deny"],
      ["err", "That when a girl walks in with an itty bitty waist"],
      ["crit", "And a round thing in your face"],
      ["debug", "You get sprung, wanna pull out your tough"],
    ]
  end
end
