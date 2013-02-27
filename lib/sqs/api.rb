require 'sqs'

class SQS::API
  @@logger = nil
  
  class << self
    
    def setup(config_file)
      init_logger
      load_config(config_file)
    end

    def init_logger
      @@logger = Logger.new(STDERR)
      @@logger.level= Logger::DEBUG
    end

    def config
      return SQS::API::Config.instance
    end
      
    def logger
      return @@logger
    end

    def debug(msg)
      logger.debug(msg)
    end

    def info(msg)
      logger.info(msg)
    end

    def warn(msg)
      logger.warn(msg)
    end

    def error(msg)
      logger.error(msg)
    end
      
    protected
    def load_config(file)
      SQS::API::Config.load(file)
    end
  end
end

require 'sqs/api/config'

