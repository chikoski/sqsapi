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
      open_sqs(params){|fd|
        sqs = fd.path
        pdf = exporter.export_pdf(sqs, File.expand_path(filename, SQS::API.config.public_dir))
        mimetype = SQS::API.config.pdf["mime_type"] || "applicatoin/pdf"
        return {filename: File.basename(filename), file: pdf, code: 200, type: mimetype}
      }
    rescue => e
      SQS::API.logger.debug(e.to_s)
      SQS::API.logger.debug(e.backtrace.join("\n"))
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

  def open_sqs(params)
    handle = file_handle(params)
    yield(handle) if block_given?
    handle.close(handle)
  end

  def filename_of(params)
    return params[:file][:filename] if params[:file] && params[:file][:tempfile]
    return params["file"][:filename].path if params["file"] && params["file"][:tempfile]
    return File.basename(URI.parse(params[:url]).path) if is_valid_url?(params)
    return nil
  end


  def file_handle(params)
    return params[:file][:tempfile] if params[:file] && params[:file][:tempfile]
    return params["file"][:tempfile] if params["file"] && params["file"][:tempfile] 
    return fetch_from(params[:url]) if is_valid_url?(params)
    return nil
  end

  def fetch_from(url)
    # XXX to be implemented
  end

  def save_as(src, filename)
    filename = File.expand_path(new_name_of(filename), ENV["HOME"])
    open(filename){|fd|
      fd.puts fd.read
    }
    return filename
  end

  def new_name_of(filename)
    name = File.basename(filename)
    postfix = File.extname(filename)

    without_postfix = name.gsub(/#{postfix}$/, "")
    return "#{without_postfix}-#{Time.now.to_i}#{postfix}"
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
