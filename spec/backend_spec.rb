require 'remote_syslog/backend'
require 'syslog_daemon'

describe RemoteSyslog::Backend do
  describe "#alive?" do
    let(:syslog) { SyslogDaemon.new(2323) }

    after { syslog.close }

    it "returns false if the backend is up" do
      backend = RemoteSyslog::Backend.new(syslog.address)

      backend.alive?.should be_true
    end

    it "returns false if the backend is down" do
      backend = RemoteSyslog::Backend.new("localhost:4242")

      backend.alive?.should be_false
    end

    it "returns false if the backend fails to send data" do
      backend = RemoteSyslog::Backend.new(syslog.address)
      syslog.close

      backend.send("HI THERE")

      backend.alive?.should be_false
    end
  end
end
