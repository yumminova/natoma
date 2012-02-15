require 'rubygems' if RUBY_VERSION < '1.9'
require 'sinatra/base'
require 'redis'
require 'resque'
require 'haml'
require 'open4'
include Open4

DEBUG = true

$redis = Redis.new
Resque.redis = $redis

class NilClass
  def method_missing(*args, &block)
    nil
  end
end

class Central < Sinatra::Base

  def initialize
    super
    # read the config file
    @config = File.exists?("config/config.yml") ? YAML.load_file("config/config.yml") : {}
  end

  set :method_override, true
  def self.debug msg
    puts "d-_-b #{msg}" if DEBUG
  end

  def self.redis; $redis; end
  def self.counter; redis.incr "global_counter"; end

  def self.crumb name, link = nil
    crumb = {}
    crumb[:name] = name
    crumb[:link] = link
    crumb
  end

  def self.scheduler
    @scheduler = Scheduler.instance
  end

  get '/' do
    @environments = redis.smembers("environments")
    @active = Central.crumb("Dashboard", request.path_info)
    haml :index
  end

end

# Since we don't want resque workers running the scheduler, we check for
# QUEUE in the environment, which means it's a worker looking at a queue
# TODO: Split the workers out better so we don't have to load the entire
# stack every time
require './lib/scheduler'

require './lib/libraries'