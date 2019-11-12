# frozen_string_literal: true

require "logger"


module Bullhorn
  #
  # A Multi logger :)
  # Centralizes the orchestration of multiple loggers, like a Composite.
  #
  # Inspired in https://gist.github.com/clowder/3639600
  #
  class MultiLogger
    attr_reader :level, :loggers

    def initialize(level: :debug, loggers: nil)
      @level = level || Logger::Severity::DEBUG
      @loggers = []

      Array(loggers).each { |logger| add_logger(logger) }
    end

    def add_logger(logger)
      logger.level = level
      @loggers << logger
    end

    def level=(level)
      @level = level
      @loggers.each { |logger| logger.level = level }
    end

    def close
      @loggers.map(&:close)
    end

    def add(level, *args)
      @loggers.each { |logger| logger.add(level, *args) }
    end
    alias log add

    Logger::Severity.constants.each do |level|
      level_name = level.downcase.to_sym

      define_method(level_name) do |*args|
        @loggers.each do |logger|
          logger.send(level_name, *args) if logger.respond_to? level_name
        end
      end

      define_method("#{level_name}?") do
        @level <= Logger::Severity.const_get(level)
      end
    end
  end
end
