require 'socket'
require 'thread'

class SyslogDaemon
  attr_reader :port

  def initialize(port)
    @port = port
    @queue = Queue.new
    @server = TCPServer.new(port)
    @packets = []
    @thread = Thread.new do
      loop do
        client = @server.accept
        while message = client.gets
          @queue << message
        end
      end
    end
  end

  def close
    @server.close unless @server.closed?
  end

  def address
    "localhost:#{port}"
  end

  def packets
    read_packets!
    @packets
  end

  private

  def read_packets!
    loop do
      sleep 0.01
      break if @queue.empty?
      packet = SyslogProtocol.parse(@queue.pop)
      @packets << packet
    end
  end
end
