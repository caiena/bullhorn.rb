# frozen_string_literal: true

require_relative "simple_logger"


module Bullhorn
  # adapts NewRelic agent error logging API to Ruby Logger
  # @see https://docs.newrelic.com/docs/agents/ruby-agent/api-guides/sending-handled-errors-new-relic
  class NewRelicLogger < SimpleLogger

    # TODO: should we implement LogDevice?
    # --
    # class LogDevice < ::Logger::LogDevice
    #   def initialize(*_args)
    #     mon_initialize
    #   end
    #
    #   def close
    #   end
    #
    #   def reopen(_log = nil)
    #     self
    #   end
    #
    #   # override
    #   def write(message, **options)
    #     begin
    #       synchronize do
    #         begin
    #           @dev.write(message)
    #         rescue
    #           warn("log writing failed. #{$!}")
    #         end
    #       end
    #     rescue Exception => ignored
    #       warn("log writing failed. #{ignored}")
    #     end
    #   end
    # end

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
    # Adapting custom write to New Relic's exception handling API
    def write(_severity, message, _progname, newrelic: nil)
      newrelic ||= {}
      # @see http://www.rubydoc.info/github/newrelic/rpm/NewRelic/Agent#notice_error-instance_method
      # Options Hash (options):
      # ---
      # :custom_params (Hash) - Custom parameters to attach to the trace
      # :expected (Boolean) - Only record the error trace (do not affect error rate or Apdex status)
      # :uri (String) - Request path, minus request params or query string (usually not needed)
      # :metric (String) - Metric name associated with the transaction (usually not needed)
      ::NewRelic::Agent.notice_error message, **newrelic
    end

  end
end
