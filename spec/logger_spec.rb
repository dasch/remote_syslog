require 'remote_syslog/logger'
require 'syslog_daemon'

describe RemoteSyslog::Logger do
  let(:port) { 2323 }
  let(:syslog) { SyslogDaemon.new(port) }
  let(:logger) { RemoteSyslog::Logger.new(syslog.address) }

  it "sends messages to a remote syslog daemon" do
    logger.info "TESTING 1-2-3"

    syslog.packets.map(&:content).should == ["TESTING 1-2-3"]
  end

  it "supports all the log levels" do
    logger.debug("I like big butts")
    logger.info("And I cannot lie")
    logger.warn("You other brothers can't deny")
    logger.error("That when a girl walks in with an itty bitty waist")
    logger.fatal("And a round thing in your face")
    logger.unknown("You get sprung, wanna pull out your tough")

    syslog.packets.map {|p| [p.severity_name, p.content] }.should == [
      ["debug", "I like big butts"],
      ["info",  "And I cannot lie"],
      ["warn",  "You other brothers can't deny"],
      ["err",   "That when a girl walks in with an itty bitty waist"],
      ["crit",  "And a round thing in your face"],
      ["debug", "You get sprung, wanna pull out your tough"],
    ]
  end
end
