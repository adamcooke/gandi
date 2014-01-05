require 'xmlrpc/client'
require 'gandi/zlib_parser_decorator'
require 'gandi/version'
require 'gandi/price'
require 'gandi/contact'
require 'gandi/domain'
require 'gandi/operation'

module Gandi
    
    class Error < StandardError; end
    class DataError < Error; end
    class ServerError < Error; end
    class ValidationError < Error; end
  
  
  class << self
    attr_accessor :apikey
    attr_accessor :mode
    
    def endpoint
      mode == 'live' ? 'https://rpc.gandi.net/xmlrpc/' : 'https://rpc.ote.gandi.net/xmlrpc/'
    end
    
    def client
      @client ||= begin
        XMLRPC::Config.module_eval do
          remove_const(:ENABLE_NIL_PARSER)
          const_set(:ENABLE_NIL_PARSER, true)
        end
        client = XMLRPC::Client.new2(self.endpoint)
        client.http_header_extra = {"Accept-Encoding" => "gzip"}
        client.set_parser ZlibParserDecorator.new(client.send(:parser))
        client
      end
    end
    
    def call(name, *args)
      client.call(name, apikey, *args)
    rescue XMLRPC::FaultException => e
      raise(e.faultCode < 500000 ? ServerError : DataError, e.faultString)
    end
  end
end
