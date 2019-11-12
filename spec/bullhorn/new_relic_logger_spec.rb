# frozen_string_literal: true

require "bullhorn/new_relic_logger"
require "new_relic/agent" # requiring the class itself, not the "newrelic_rpm"


RSpec.describe Bullhorn::NewRelicLogger do

  it "allows instantiating without a log device (logdev)" do
    expect { Bullhorn::NewRelicLogger.new }.not_to raise_error
  end

  context "logger level" do
    it "instantiates logger with level :error" do
      logger = Bullhorn::NewRelicLogger.new
      expect(logger.level).to eq Logger::ERROR
    end

    it "ignores any argument trying to define the logger level" do
      logger = Bullhorn::NewRelicLogger.new nil, level: Logger::DEBUG
      expect(logger.level).to eq Logger::ERROR
    end

    it "ignores setter method for #logger=" do
      logger = Bullhorn::NewRelicLogger.new
      logger.level = Logger::DEBUG
      expect(logger.level).to eq Logger::ERROR
    end
  end

  # TODO: it_behaves_like Bullhorn::SimpleLogger

  it "ignores any log severity lower than :error (:debug, :info, :warn)" do
    logger = Bullhorn::NewRelicLogger.new

    expect(logger).not_to receive :write

    logger.debug "ignored"
    logger.info  "ignored"
    logger.warn  "ignored"
  end

  it "processes any log severity greather than or equal to :error (:error, :fatal)" do
    logger = Bullhorn::NewRelicLogger.new

    expect(logger).to receive(:write).twice

    logger.error "processed"
    logger.fatal "processed"
  end


  it "implements #write, handling newrelic: options" do
    logger = Bullhorn::NewRelicLogger.new
    message = "log message"
    options = { custom_params: { something: "else" }, expected: true }

    expect(NewRelic::Agent).to receive(:notice_error).with(message, options).once

    logger.error message, newrelic: options
  end
end
