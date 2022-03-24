require 'logger'

class FakeLogger
  attr_reader :logs

  def initialize(log:)
    @log = log
    @logs = []
    @logger = Logger.new(STDERR)
  end

  def debug(msg)
    @logs << [:debug, msg]
    @logger.debug(msg) if @log
  end

  def info(msg)
    @logs << [:info, msg]
    @logger.info(msg) if @log
  end
end
