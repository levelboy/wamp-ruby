require '../lib/wamp'
require 'json'
require 'pry'
require 'simple_router'

class Application1 < WAMP::Server
  include SimpleRouter::DSL

  def initialize(options = {})
  	super(options)
  end

  get '/' do |params|
    'home'
  end

  post '/' do |context, data|
  	puts 'posted data ' + data.inspect
  	sender_id = data['registration_id']
  	event_data = data['event']
  	client = context.engine.clients[sender_id]
  	topic_uri, payload, excluded_clients, included_clients = event_data

  	context.engine.create_event(client, topic_uri, payload, excluded_clients, included_clients)
      context.trigger(:publish, client, topic_uri, payload, excluded_clients, included_clients)

    data
  end
end

App = Application1.new

def log(text)
  puts "[#{Time.now}] #{text}"
end

App.bind(:connect) do |client, clients|
  log "#{client.id} connected"
end

App.bind(:prefix) do |client, prefix, uri|
  log "#{client.id} negotiated #{prefix} as #{uri}"
  log "#{client.id} prefixes: #{client.prefixes.to_s}"
end

App.bind(:subscribe) do |client, topic|
  log "#{client.id} subscribed to #{topic}"
end

App.bind(:unsubscribe) do |client, topic|
  log "#{client.id} unsubscribed from #{topic}"
end

App.bind(:publish) do |client, topic, data|
  log "#{client.id} published #{data} to #{topic}"
end

App.bind(:disconnect) do |client|
  log "#{client.id} disconnected"
end