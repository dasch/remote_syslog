require 'syslog_protocol'

module RemoteSyslog
  class Logger
    SEVERITIES = %w(debug info warn error fatal unknown)

    SEVERITY_MAPPING = {
      "error"   => "err",
      "fatal"   => "crit",
      "unknown" => "debug",
    }

    def initialize(*addresses)
      @addresses = addresses
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
      @socket ||= first_working_socket
    end

    def first_working_socket
      @addresses.each do |address|
        begin
          host, port = address.split(":")
          return TCPSocket.new(host, port)
        rescue Errno::ECONNREFUSED
          next
        end
      end
    end
  end
end
