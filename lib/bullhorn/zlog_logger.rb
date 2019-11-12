# frozen_string_literal: true

require "json" # to format messages as Zlog requires (JSON)
require "zlog/bunny_logger"
require_relative "simple_logger"


module Bullhorn
  # adapts Zlog API to Ruby Logger api
  # @see https://github.com/dpedoneze/zlog
  class ZlogLogger < SimpleLogger
    # Allow nil logdev, since we're overriding the #add method
    def initialize(logdev = nil, *_args)
      super
    end


    # @implement
    # Adapting custom write to Zlog's message publishing API
    def write(severity, message, _progname, zlog: nil)
      zlog ||= {}
      zlog_publisher.publish build_message(severity_name_for(severity), message)
    end


    private

    # TODO: wait for zlog to be updated and redesign this "adapter"
    # adjusting options for https://github.com/dpedoneze/zlog/blob/63706cc678b5dc52f6c8425ea5642f8444321743/lib/zlog/bunny_logger.rb
    class ZlogBunnyLoggerExt < ::Zlog::BunnyLogger
      def initialize(queue_name = "logger")
        @queue_name = queue_name
        @connection = ::Bunny.new bunny_options # XXX: this is the overriden piece. the
        @connection.start

        # XXX: and this is the missing bind between queue and exchange...
        queue.bind exchange, routing_key: queue.name
      end
    end

    def zlog_publisher
      @zlog_publisher ||= ZlogBunnyLoggerExt.new
    end

    def build_message(severity, message)
      {
        severity:  severity,
        message:   message,
        host:      "-",
        timestamp: Time.now.iso8601 # strftime("%F %H:%M:%S %z")
      }.to_json
    end

  end
end
