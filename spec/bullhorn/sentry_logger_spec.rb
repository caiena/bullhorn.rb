# frozen_string_literal: true

require "bullhorn/sentry_logger"

RSpec.describe Bullhorn::SentryLogger do

  it "allows instantiating without a log device (logdev)" do
    expect { Bullhorn::SentryLogger.new }.not_to raise_error
  end

  context "logger level" do
    it "instantiates logger with level :error" do
      logger = Bullhorn::SentryLogger.new
      expect(logger.level).to eq Logger::ERROR
    end

    it "ignores any argument trying to define the logger level" do
      logger = Bullhorn::SentryLogger.new nil, level: Logger::DEBUG
      expect(logger.level).to eq Logger::ERROR
    end

    it "ignores setter method for #logger=" do
      logger = Bullhorn::SentryLogger.new
      logger.level = Logger::DEBUG
      expect(logger.level).to eq Logger::ERROR
    end
  end

  # TODO: it_behaves_like Bullhorn::SimpleLogger

  it "ignores any log severity lower than :error (:debug, :info, :warn)" do
    logger = Bullhorn::SentryLogger.new

    expect(logger).not_to receive :write

    logger.debug "ignored"
    logger.info  "ignored"
    logger.warn  "ignored"
  end

  it "processes any log severity greather than or equal to :error (:error, :fatal)" do
    logger = Bullhorn::SentryLogger.new

    expect(logger).to receive(:write).twice

    logger.error "processed"
    logger.fatal "processed"
  end


  it "implements #write, handling sentry: options" do
    logger = Bullhorn::SentryLogger.new
    message = "log message"
    options = { level: "error", extra: { something: "else" } }

    expect(Sentry).to receive(:capture_message).with(message, options).once

    logger.error message, sentry: options
  end

  it "handles logging exceptions with specific Sentry API" do
    logger = Bullhorn::SentryLogger.new
    message = Exception.new "log message two"
    options = { level: "error", extra: { something: "else" } }
    expect(Sentry).to receive(:capture_exception).with(message, options).once

    logger.error message, sentry: options
  end
end
