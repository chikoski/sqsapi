require 'yaml'
require 'logger'

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

    protected
    def load_config(file)
      SQS::API::Config.load(file)
    end

  end
    
end

class SQS::API::Config
  # XXX default value...
  @@instance = nil
  
  def initialize(yml_file)
    unless @@instance
      @yml = YAML.load_file(yml_file)
      expand_paths(yml_file)
      @@instance = self
    end
  end

  protected
  def expand_paths(yml_file)
    @yml[:config_file] = yml_file
    @yml[:config_dir] = File.dirname(yml_file)
    @yml[:root_dir] = File.expand_path("..", @yml[:config_dir])
    @yml[:fixture_dir] = File.expand_path(@yml[:fixture_dir], @yml[:root_dir])
  end

  def method_missing(name, *args)
    return @yml[name]
  end

  class << self

    def instance
      return @@instance
    end

    alias :load :new
    
  end
  
end
