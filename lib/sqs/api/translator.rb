# -*- coding: utf-8 -*-
require 'uri'
require 'open-uri'
require 'singleton'

class SQS::API::Translator
  include Singleton

  def start(params)
    begin
      sqs = sqs_file_handle(params)
      pdf = translate(sqs)
      return {filename: filename, file: pdf, code: 200, type: SQS::API.config.pdf[:mime_type]}
    rescue => e
      SQS::API.logger.debug(e.to_s)
      return translate_error(:no_sqs_file) 
    end
  end

  protected
  def translate_error(reason)
    return {
      code: 400,
      reason: reason
    }
  end
  
  # XXX
  # 未実装。とりあえずPDF返す
  def translate(sqs)
    ret = nil
    conf = SQS::API.config
    open(File.expand_path("pdf/2965.pdf", conf.fixture_dir), "rb"){|fd|
      ret = fd.read
    }
    return ret
  end

  def filename
    return "#{Time.now.to_i}.pdf"
  end

  def is_valid_url?(params)
    url = params[:url]
    begin
      url = URI.parse(url)
      return true if url.scheme == "http"
      return false 
    rescue
      return false
    end
  end
  
  def is_valid_enctype?(enctype)
    return enctype == "multipart/form-data"
  end
  
  def to_read_from_file?(params)
    return params[:file] && is_valid_enctype?(params[:enctype])
  end
  
  def sqs_file_handle(params)
    return params[:file][:tmpfile] if to_read_from_file?(params)
    return open(params[:url]) if is_valid_url?(params)
    return nil
  end

  class << self

    def start(params)
      SQS::API.logger.debug(params)
      return instance.start(params)
    end
    
  end
  
end
