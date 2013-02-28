class SQS::API::Exporter
  GROUP_ID = "sqs"
  APP_ID = "SQS Translator API"
  
  import "net.sqs2.translator.impl"
  import "net.sqs2.net"

  def initialize
    @uri_resolver = ClassURIResolver.new()
    @page_setting = PageSettingImpl.new(595, 842)
  end

  def export_pdf(file, pdffile)
    file = file.path if file.is_a?(File)
    sqs = java.io.File.new(file)
    pdf = translate(sqs, pdffile)
    return pdf.getAbsolutePath()
  end

  protected
  def translate(sqs, pdffile)
    sqs_fd = java.io.BufferedInputStream.new(java.io.FileInputStream.new(sqs))

    pdf = java.io.File.new(pdffile)
    pdf.createNewFile()
    pdf_fd = java.io.BufferedOutputStream.new(java.io.FileOutputStream.new(pdf))

    translator_for(pdf.getName()) do |t|
      t.execute(sqs_fd, sqs.toURI().toString(),  pdf_fd, @uri_resolver)
    end

    return pdf
  end
  
  def translator_for(filename, lang="ja")
    ret = SQSToPDFTranslator.new(GROUP_ID,
                                 APP_ID,
                                 TranslatorJarURIContext.getFOPBaseURI(), 
                                 TranslatorJarURIContext.getXSLTBaseURI(), 
                                 lang,
                                 filename,
                                 @uri_resolver,
                                 @page_setting)
    yield(ret) if block_given?
    return ret
  end

  
  
end
