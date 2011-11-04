require 'sinatra'

def debug msg
  puts "d-b #{msg}"
end

# further requires (models, helpers, core extensions etc. { but not 'middleware' because that should be grabbed up by Rack when appropriate })
Dir.glob('./application/**/*.rb') do |file|
  require file.gsub(/\.rb/, '') unless file.include?('middleware')
end

get '/' do
  @title = 'CENTRAL'
  
  erb :index
end

post '/servers' do
  Resque.enqueue(ServerCreate, params[:name])
  redirect to('/')
end
