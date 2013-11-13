# RemoteSyslog

Allows streaming log messages to any Syslog compliant log server. The messages
will be streamed over TCP, ensure reliable delivery.

It is possible to configure RemoteSyslog with multiple Syslog backends - if a
backend fails, another will be chosen instead.

## Installation

Add this line to your application's Gemfile:

    gem 'remote_syslog'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install remote_syslog

## Usage

```ruby
logger = RemoteSyslog::Logger.new("syslog1.example.com:6514", "syslog2.example.com:6514")
logger.info "HELLO WORLD!"
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
