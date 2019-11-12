# frozen_string_literal: true

require "logger"


module Bullhorn
  #
  # A base class to ease the creation of custom loggers without having to define LogDevine and
  # extending its capabilities to forward an `**options` argument to logger methods.
  #
  # usage:
  # ```ruby
  # require "bullhorn/simple_logger"
  #
  # class MyLogger < ::Bullhorn::SimpleLogger
  #   # just override this method and you should be good to go
  #   # @implement
  #   # Adapting custom write to New Relic's exception handling API
  #   def write(severity, message, progname, **options)
  #     severity_name = severity_name_for severity
  #
  #     # a "dummy" puts logger
  #     puts "#{Time.now.utc} - [#{severity_name}] (#{progname}) #{message}"
  #   end
  # end
  #
  # logger = MyLogger.new level: :debug, progname: "my-app"
  # logger.debug "something"
  # # => 2019-11-12 18:39:11 UTC - [debug] (my-app) something
  # ```
  class SimpleLogger < ::Logger

    # @override
    # extending to allow custom extensions with **options argument
    def add(severity, message = nil, progname = nil, **options)
      # this source code was copied from Ruby's standard Logger class.
      # We have overriden its signature (args), allowing **options to be passed, and
      # we removed a check for @logdev.nil? in early return for severity check.
      severity ||= ::Logger::UNKNOWN
      return true if severity < @level

      progname ||= @progname
      if message.nil?
        if block_given?
          message = yield
        else
          message = progname
          progname = @progname
        end
      end
      # replacing @logdev.write with custom method #write, which must be implemented in subclasses.
      # @logdev.write(format_message(format_severity(severity), Time.now, progname, message))
      write severity, message, progname, **options
      true
    end


    def write(severity, message, progname, **options) # rubocop:disable UnusedMethodArgument
      raise NotImplementedError
    end

    # @override
    # extending to allow custom extensions with **options argument
    def debug(progname = nil, **options, &block)
      add ::Logger::DEBUG, nil, progname, **options, &block
    end

    # @override
    # extending to allow custom extensions with **options argument
    def error(progname = nil, **options, &block)
      add ::Logger::ERROR, nil, progname, **options, &block
    end

    # @override
    # extending to allow custom extensions with **options argument
    def fatal(progname = nil, **options, &block)
      add ::Logger::FATAL, nil, progname, **options, &block
    end

    # @override
    # extending to allow custom extensions with **options argument
    def info(progname = nil, **options, &block)
      add ::Logger::INFO, nil, progname, **options, &block
    end

    # @override
    # extending to allow custom extensions with **options argument
    def unknown(progname = nil, **options, &block)
      add ::Logger::UNKNOWN, nil, progname, **options, &block
    end

    # @override
    # extending to allow custom extensions with **options argument
    def warn(progname = nil, **options, &block)
      add ::Logger::WARN, nil, progname, **options, &block
    end


    private

    def severity_name_for(severity)
      case severity
      when Logger::DEBUG   then "debug"
      when Logger::ERROR   then "error"
      when Logger::FATAL   then "fatal"
      when Logger::INFO    then "info"
      when Logger::UNKNOWN then "unknown"
      when Logger::WARN    then "warning"
      when Symbol then severity.to_s
      else severity
      end
    end

  end
end
