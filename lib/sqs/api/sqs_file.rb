require 'uri'

class SQS::API::SQSFile
  attr_reader :filename

  def initialize(filename)
    @filename = filename
  end

  class << self

    def open(params)
      
    end

    protected
    def to_uri(id)
      begin
        return URI.parse(id)
      rescue => e
        return nil
      end
    end
    
  end
  
end
