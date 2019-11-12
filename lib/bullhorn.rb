# frozen_string_literal: true

require_relative "bullhorn/version"
require_relative "bullhorn/multi_logger"

#
# Bullhorn is a logger composer, following Ruby Logger api.
# @see https://ruby-doc.org/stdlib-2.4.0/libdoc/logger/rdoc/Logger.html
#
# It comes bundled with a default logger, which defaults to a Logger on STDOUT, but can be overriden
# with:
# ```ruby
# Bullhorn.default_logger = SimpleLogger.new "something"
# ```
#
# usage:
# ```ruby
# # all on constructor
# sentry    = Bullhorn::SentryLogger.new *attrs    # it's fixed on :error level
# new_relic = Bullhorn::NewRelicLogger.new *attrs  # it's fixed on :error level
#
# bullhorn = Bullhorn.new level: :debug
# bullhorn.add_logger Bullhorn.default_logger
# bullhorn.add_logger sentry
# bullhorn.add_logger new_relic
#
# bullhorn.info "test"  # new_relic logger won't handle it
# ```
#
module Bullhorn
  extend self

  class Error < StandardError; end

  def new(*attrs)
    MultiLogger.new *attrs
  end

  def default_logger
    @default_logger ||= Logger.new(STDOUT, progname: "bullhorn")
  end

  def default_logger=(logger)
    @default_logger = logger
  end
end
