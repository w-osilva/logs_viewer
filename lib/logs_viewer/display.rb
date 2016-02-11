module LogsViewer
  class Display

    def initialize(app)
      @app = app
      @lines = LogsViewer::Config.number_lines
      @log_dir = LogsViewer::Config.log_dir
    end

    def call(env = {})
      if env["PATH_INFO"]=~/^\/logs/
        @data = {
          list: LogsViewer::Handler.list(@log_dir),
          lines: []
        }

        if(env["QUERY_STRING"]=~/file/ )
          log_name = env["QUERY_STRING"].clone
          log_name = log_name.gsub(/file=/, '')

          @data[:lines] = `tail -n "#{@lines}" "#{log_name}"`
          [200,{"Content-Type"=>"text/html"},[view_generate(@data)]]
        else
          [200,{"Content-Type"=>"text/html"},[view_generate(@data)]]
        end
      else
        @app.call(env)
      end
    end

    def view_generate(data)
      temp = LogsViewer::Handler.file_open("../views/display.html.erb")
      temp = ERB.new(temp)
      return temp.result(binding)
    end

  end
end