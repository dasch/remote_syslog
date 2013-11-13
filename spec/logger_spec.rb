require 'remote_syslog/logger'

describe RemoteSyslog::Logger do
  class FakeBackend
    attr_reader :messages

    def initialize
      @messages = []
      @alive = true
    end

    def exit
      @alive = false
    end

    def alive?
      @alive
    end

    def send(data)
      raise RemoteSyslog::BackendFailure unless alive?

      packet = SyslogProtocol.parse(data)
      @messages << packet.content
    end
  end

  let(:backend1) { FakeBackend.new }
  let(:backend2) { FakeBackend.new }
  let(:logger) { RemoteSyslog::Logger.new("foo", "bar") }

  before do
    RemoteSyslog::Backend.stub(:new).with("foo") { backend1 }
    RemoteSyslog::Backend.stub(:new).with("bar") { backend2 }
  end

  it "transmits log entries using the first available backend" do
    logger.info "HELO"

    backend1.messages.should == ["HELO"]
  end

  it "falls back to using the second backend if the first one doesn't work" do
    backend1.exit

    logger.info "HELO"

    backend2.messages.should == ["HELO"]
  end

  it "resends an entry using a different backend if the first one fails" do
    logger.info "HELO"

    backend1.exit

    logger.info "WORLD"

    backend1.messages.should == ["HELO"]
    backend2.messages.should == ["WORLD"]
  end

  it "fails if there are no working backends" do
    backend1.exit
    backend2.exit

    expect {
      logger.info "HELO"
    }.to raise_exception(RemoteSyslog::NoAvailableBackend)
  end
end
