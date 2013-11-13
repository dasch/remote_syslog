require 'syslog_protocol'
require 'remote_syslog/backend'

module RemoteSyslog
  class Logger
    SEVERITIES = %w(debug info warn error fatal unknown)

    SEVERITY_MAPPING = {
      "error"   => "err",
      "fatal"   => "crit",
      "unknown" => "debug",
    }

    def initialize(*addresses)
      @backends = addresses.map {|address| Backend.new(address) }
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

      begin
        backend.send(packet.assemble)
      rescue BackendFailure
        @backend = nil
        retry
      end
    end

    def map_severity(severity)
      SEVERITY_MAPPING.fetch(severity, severity)
    end

    def backend
      @backend ||= first_working_backend
    end

    def first_working_backend
      @backends.find {|backend| backend.alive? }
    end
  end
end
