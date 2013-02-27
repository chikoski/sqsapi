require 'sqs'
require 'find'

class SQS::API
  include Find
  
  @@logger = nil
  
  class << self
    
    def setup(config_file)
      init_logger
      load_config(config_file)
      load_jar_files
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

    def load_jar_files
      require 'java'

      repository = config.m2
      repository = ENV["HOME/.m2"] unless File.directory?(repository)
      find(repository){|file|
        require file if file =~ /\.jar$/
      }
    end
  end
end

require 'sqs/api/config'

