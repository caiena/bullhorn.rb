# frozen_string_literal: true

RSpec.describe Bullhorn do
  it "has a version number" do
    expect(Bullhorn::VERSION).not_to be nil
  end

  it "allows instantiating a bullhorn" do
    bullhorn = Bullhorn.new

    expect(bullhorn).to be_a Bullhorn::MultiLogger
    expect(bullhorn.loggers).to be_empty

    expect(bullhorn).to respond_to :debug
    expect(bullhorn).to respond_to :error
    expect(bullhorn).to respond_to :fatal
    expect(bullhorn).to respond_to :info
    expect(bullhorn).to respond_to :unknown
    expect(bullhorn).to respond_to :warn
  end

  it "has a ::default_logger logging to STDOUT" do
    expect do
      Bullhorn.default_logger.info "foo"
    end.to output(/bullhorn: foo$/).to_stdout_from_any_process
  end
end
