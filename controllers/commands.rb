class Central

  get '/commands' do
    @crumbs = []
    @crumbs << Central.crumb("Dashboard", "/")
    @active = Central.crumb("Commands", request.path_info)
    @commands = Command.list_all
    haml 'commands'
  end

  post '/commands' do
    id = counter
    Command.new(id).save(params)
    redirect to('/commands')
  end

  get '/commands/create' do
    @crumbs = []
    @crumbs << Central.crumb("Dashboard", "/")
    @active = Central.crumb("Commands", request.path_info)
    haml 'command_create'
  end
  
  get '/commands/:id' do
    @command = Command.new(params[:id])
    haml 'command'
  end

  # TODO: tidy this up and make it actually work
  get '/commands/:id/tail/:stream' do
    id = params[:id]
    stream do |out|
      out << "<pre>"
      out << "Tailing #{params[:stream]} for id #{params[:id]}\n\n"
      init = $redis.lrange("logs::#{params[:id]}::#{params[:stream]}", 0, -1)
      size = init.length
      Central.debug "#{id}----Size >> #{size}"
      out << init.join("\n")
      out << "\n"

      while true
        n = $redis.lrange("logs::#{params[:id]}::#{params[:stream]}", size, -1)
        if n.length > 0
          size += n.length
          Central.debug "#{id}----Size >> #{size}"
          out << n.join("\n")
          out << "\n"
        end
        sleep 1
      end
    end
  end

end