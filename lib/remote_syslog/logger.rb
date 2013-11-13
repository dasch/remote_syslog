require 'syslog_protocol'

module RemoteSyslog
  class Logger
    SEVERITIES = %w(debug info warn error fatal unknown)

    SEVERITY_MAPPING = {
      "error"   => "err",
      "fatal"   => "crit",
      "unknown" => "debug",
    }

    def initialize(address)
      @address = address
    end

    SEVERITIES.each do |severity|
      define_method(severity) {|*args| log(severity, *args) }
    end

    private

    def log(severity, message)
      packet = SyslogProtocol::Packet.new
      packet.hostname = "localhost"
      packet.facility = "user"
      packet.tag = "foo"
      packet.severity = map_severity(severity)
      packet.content = message
      socket.puts(packet.assemble)
      socket.flush
    end

    def map_severity(severity)
      SEVERITY_MAPPING.fetch(severity, severity)
    end

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
