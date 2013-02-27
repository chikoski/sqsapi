# -*- coding: utf-8 -*-
require 'uri'
require 'open-uri'
require 'singleton'
require 'sqs/api'
require 'sqs/api/exporter'

class SQS::API::Translator
  include Singleton

  def start(params)
    begin
      sqs = ""
      open(params){|fd|
        sqs = fd.read
      }
      pdf = exporter.export_pdf(sqs)
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

  def exporter
    return @exporter if @exporter
    @exporter = SQS::API::Exporter.new
  end
  
  def filename
    return "#{Time.now.to_i}.pdf"
  end

  def open(params)
    handle = file_handle(params)
    yield(handle) if block_given?
    handle.close(handle)
  end

  def file_handle(params)
    return params[:file][:tempfile] if params[:file] && params[:file][:tempfile]
    return params["file"][:tempfile] if params["file"] && params["file"][:tempfile] 
    return open(params[:url]) if is_valid_url?(params)
    return nil
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

  class << self

    def start(params)
      SQS::API.logger.debug(params)
      return instance.start(params)
    end
    
  end
  
end
