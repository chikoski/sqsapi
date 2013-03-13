class SQS::File

  class << self

    def open(params)
      handle = filehandle_of params
      yield(handle) if block_given?
      handle.close
    end

    protected
    def filename_of(params)
      return params[:file][:filename] if params[:file] && params[:file][:tempfile]
      return params["file"][:filename].path if params["file"] && params["file"][:tempfile]
      return nil
    end
    
    def filehandle_of(params)
      return tempfile_for params[:s] if params[:s]
      return tempfile_for params["s"] if params["s"]
      return params[:file][:tempfile] if params[:file] && params[:file][:tempfile]
      return params["file"][:tempfile] if params["file"] && params["file"][:tempfile] 
      return nil
    end

    def tempfile_for(str)
      tmpdir = SQS::API.config.tmp_dir || ENV['TMP'] || ENV['HOME']
      path = File.expand_path(tmpfilename, tmpdir)
      open(path){|fd|
        fd.puts str
      }
      return File.new(tmpdir)
    end

    def tempfilename
      return "#{Time.now.to_i}.sqs"
    end
    
  end
  
end
