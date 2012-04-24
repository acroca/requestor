require 'typhoeus'
require 'nokogiri'
require 'redis'

class Requestor
  
  def initialize(url, selector, callback_url)
    @url = url
    @selector = selector
    @callback_url = callback_url
  end

  def process
    query_url do |content|
      if previous_content != content

        set_content content
        query_callback
      end
    end    
    
    hydra.run
  end

  private

  def hydra
    @hydra ||= Typhoeus::Hydra.hydra
  end

  def redis
    uri = URI.parse('redis://localhost:6379')
    Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)  
  end

  def query_url
    request = Typhoeus::Request.new(@url)

    request.on_complete do |response|
      element = Nokogiri::HTML(response.body).css(@selector)
      content = element.first.children.first.content
      yield content
    end

    hydra.queue request
  end

  def query_callback
    request = Typhoeus::Request.new(@callback_url)
    hydra.queue request
  end

  def previous_content
    @previous_content ||= redis.get("#{@url} - #{@selector}")
  end

  def set_content(content)
    redis.set("#{@url} - #{@selector}", content)
  end
end