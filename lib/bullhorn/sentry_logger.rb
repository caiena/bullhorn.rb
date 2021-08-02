# frozen_string_literal: true

require_relative "simple_logger"


module Bullhorn
  # adapts Sentry API to Ruby Logger api
  # @see https://docs.sentry.io/clients/ruby/context/
  class SentryLogger < SimpleLogger

    # @override
    # Allow nil logdev, since we're overriding the #add method
    def initialize(logdev = nil, *_args)
      super

      # fixing it on error level
      @level = Logger::Severity::ERROR
    end

    # @override
    # We're not letting anyone change the level of this logger, because NewRelic only understands
    # errors/exceptions!
    def level=(*args)
      # no-op
    end

    # @implement
    # Adapting custom write to Sentry Ravens's capture message API
    def write(severity, message, _progname, sentry: nil)
      sentry ||= {}
      sentry_options = sentry.merge level: severity_name_for(severity)
      # - defined options are:
      # logger: the logger name to record this event under
      # level: a string representing the level of this event (fatal, error, warning, info, debug)
      # server_name: the hostname of the server
      # tags: a mapping of tags describing this event
      # extra: a mapping of arbitrary context
      # user: a mapping of user context
      # transaction: An array of strings. The final element in the array represents the current transaction, e.g. “HelloController#hello_world” for a Rails controller.

      if message.is_a?(Exception) # and severity >= Logger::ERROR
        # @see https://docs.sentry.io/clients/ruby/usage/#reporting-failures
        Sentry.capture_exception message, **sentry_options
      else
        # @see https://docs.sentry.io/clients/ruby/usage/#reporting-messages
        # @see https://docs.sentry.io/clients/ruby/context/
        Sentry.capture_message message, **sentry_options
      end
    end

  end
end
