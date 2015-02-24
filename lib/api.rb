require_relative 'log'
require 'httplog'
require 'rest-client'
require 'recursive_open_struct'

module Skytap
  class API
    MAX_RETRIES = 5
    SLEEP_BETWEEN_RETRIES_SECS = 20

    HttpLog.options[:logger] = Log.logger
    HttpLog.options[:log_headers] = true

    def self.post(url, body=nil)
      api_call(:post, url, body)
    end

    def self.put(url, body=nil)
      api_call(:put, url, body)
    end

    def self.get(url)
      api_call(:get, url)
    end

    def self.delete(url)
      api_call(:delete, url)
    end

    private

    def self.api_call(method, url, body=nil, retries=0)
      Log.info("Skytap API Request: Method: #{method}, URL: #{url}, Body: #{body}, Retries: #{retries}")

      @api ||= RestClient::Resource.new(Settings.skytap.api_url,
        user: Settings.skytap.user,
        password: Settings.skytap.api_key,
        headers: {accept: :json, content_type: :json}
      )

      url = url[1..-1] if url.start_with?('/')

      begin
        if method == :get
          output = @api[url].send(method)          
        else
          output = @api[url].send(method, body ? body.to_json : nil)
        end
      rescue RestClient::Exception => ex
        if ex.http_code == 423
          raise if retries >= MAX_RETRIES

          Log.warn("Got busy response... will sleep #{SLEEP_BETWEEN_RETRIES_SECS} seconds and retry")
          sleep SLEEP_BETWEEN_RETRIES_SECS
          self.api_call(method, url, body, i+1)
        else
          raise
        end
      end

      resp = JSON.parse(output, symbolize_names: true)
      resp.is_a?(Array) ? resp.map {|obj| RecursiveOpenStruct.new(obj, recurse_over_arrays: true)} : RecursiveOpenStruct.new(resp, recurse_over_arrays: true)
    end
  end
end