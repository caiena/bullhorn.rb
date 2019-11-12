# Bullhorn

You use a bullhorn to make more listeners hear the same message, right?
Now you can use one too to make `Loggers` hear the same message.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "bullhorn"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bullhorn

## Usage

### Create your bullhorn and start adding loggers to it:
```ruby
require "bullhorn"

bullhorn = Bullhorn.new # default level defaults to DEBUG

stdout_logger = Logger.new STDOUT
file_logger = Logger.new "app.log"

bullhorn.add_logger stdout_logger
bullhorn.add_logger file_logger

bullhorn.debug "Meet me on STDOUT and in app.log file!"
```

### Writing your own custom logger
```ruby
require "bullhorn/simple_logger"

class MyLogger < ::Bullhorn::SimpleLogger
  # just implement this method and you should be good to go
  def write(severity, message, progname, **options)
    severity_name = severity_name_for severity

    # a "dummy" puts logger
    puts "#{Time.now.utc} - [#{severity_name}] (#{progname}) #{message}"
  end
end

logger = MyLogger.new level: :debug, progname: "my-app"
logger.debug "something"
# => 2019-11-12 18:39:11 UTC - [debug] (my-app) something
```

### And now use it with your bullhorn
```ruby
require "bullhorn"
require "my_logger" # make sure it reflects your logger class file location

bullhorn = Bullhorn.new

stdout_logger = Logger.new STDOUT
file_logger = Logger.new "app.log"
my_logger = MyLogger.new level: :warn # making it respond to :warn level and above

bullhorn.debug "my_logger can't hear me!"
bullhorn.warn "now my_logger can hear me!"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/caiena/bullhorn.rb.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
