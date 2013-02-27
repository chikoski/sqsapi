require 'java'
require 'sqs-translator-1.1.2.jar'

class SQS::API::Exporter
  include Java

  GROUP_ID = "sqs"
  APP_ID = "SQS Translator API"

  def initialize
    @uri_resolver = net.sqs2.net.ClassURIResolver.new()
    @page_setting = net.sqs2.translator.impl.PageSettingImpl.new(595, 842)
  end

  def export_pdf(exporting_file, uri_resolver, page_setting)
    sqs = org.jruby.util.JRubyFile.new(exporting_file.path)
    pdf = translate(sqs)
    return pdf
  end

  protected

  def traslate(sqs)
    sqs_fd = java.io.BufferedInputStream.new(java.io.FileInputStream.new(file))

    pdf = org.jruby.util.JRubyFile.createTempFile("sqs", "pdf")
    pdf_fd = java.io.BufferedOutputStream.new(java.io.FileOutputStream.new(pdf))

    translator.execute(sqs_fd, sqs.toURI(),  pdf_fd, uriResolver)

    return pdf
  end
  
  def translator
    return @sqs_pdf_translator if @sqs_pdf_translator
    @sqs_pdf_translarator =
      net.sqs2.translator.impl.SQSToPDFTranslator(GROUP_ID,
                                                  APP_ID,
                                                  "ja",
                                                  @uri_resolver,
                                                  @page_setting)
    return @sqs_pdf_translarator
  end

  
  
end
