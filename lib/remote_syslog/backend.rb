require 'socket'

module RemoteSyslog
  BackendFailure = Class.new(StandardError)

  class Backend
    def initialize(address)
      @address = address
      @socket = build_socket
    end

    def send(data)
      socket.puts(data)
      socket.flush
    rescue Errno::EPIPE
      @socket = nil
    end

    def alive?
      !socket.nil?
    end

    private

    attr_reader :socket

    def build_socket
      host, port = @address.split(":")
      return TCPSocket.new(host, port)
    rescue Errno::ECONNREFUSED
      nil
    end
  end
end
