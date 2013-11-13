module RemoteSyslog
  class Logger
    def initialize(address)
      @address = address
    end

    def info(message)
      socket.write(message)
      socket.close
    end

    private

    def socket
      @socket ||= TCPSocket.new(host, port)
    end

    def host
      address_parts[0]
    end

    def port
      address_parts[1]
    end

    def address_parts
      @address.split(":")
    end
  end
end
