require 'faraday'
require 'SecureRandom'
require 'json'

class PiClient

  attr_reader :config_file, :base_uri, :conn

  def initialize(args)
    @config_file = 'config.json'
    @base_uri = "http://233f9466.ngrok.com"
    @conn = Faraday.new(url: @base_uri)
  end
  
  def config
    file = File.read(config_file)
    @config = JSON.parse(file)
    if @config['uuid'] == ""
      @config['uuid'] = generate_uuid
    end
    save_config
    @config
  end
  
  def check_existance?
    response = conn.get "#{@base_uri}/devices/#{@config['uuid']}" do |request|
      request.headers['Content-Type'] = 'application/json'
      request.body
    end
    response.body
  end
  
  def start_existance!
    conn.post "#{@base_uri}/devices.json" do |request|
      request.headers['Content-Type'] = 'application/json'
      request.body = @config.to_json
    end
  end
  
  private
  
  def generate_uuid
    SecureRandom.uuid
  end
  
  def save_config
    File.open(config_file,"w") do |f|
      f.write(@config.to_json)
    end
  end
end

pic = PiClient.new("")

pic.config
pic.start_existance!
puts pic.check_existance?