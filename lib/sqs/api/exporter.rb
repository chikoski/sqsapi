class SQS::API::Exporter
  GROUP_ID = "sqs"
  APP_ID = "SQS Translator API"
  
  import "net.sqs2.translator.impl"
  import "net.sqs2.net"

  def initialize
    @uri_resolver = ClassURIResolver.new()
    @page_setting = PageSettingImpl.new(595, 842)
  end

  def export_pdf(file)
    file = file.path if file.is_a?(File)
    sqs = java.io.File.new(file)
    pdf = translate(sqs)
    return pdf
  end

  protected
  def translate(sqs)
    sqs_fd = java.io.BufferedInputStream.new(java.io.FileInputStream.new(sqs))

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
