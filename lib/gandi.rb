require 'xmlrpc/client'
require 'gandi/zlib_parser_decorator'
require 'gandi/version'
require 'gandi/price'

module Gandi
  class << self
    attr_accessor :apikey
    attr_accessor :mode
    
    def endpoint
      mode == 'live' ? 'https://rpc.gandi.net/xmlrpc/' : 'https://rpc.ote.gandi.net/xmlrpc/'
    end
    
    def client
      @client ||= begin
        client = XMLRPC::Client.new2(self.endpoint)
        client.http_header_extra = { "Accept-Encoding" => "gzip" }
        client.set_parser ZlibParserDecorator.new(client.send(:parser))
        client
      end
    end
  end
end
