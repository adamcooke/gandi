module Gandi
  class Price
    
    attr_accessor :action
    attr_accessor :description
    attr_accessor :price
    attr_accessor :min_duration
    attr_accessor :max_duration
    attr_accessor :currency
    attr_accessor :grid
    attr_accessor :duration_unit

    def self.find(domain, options = {})
      options[:action]    ||= 'create'
      options[:duration]  ||= 1
      options[:currency]  ||= 'GBP'
      options[:grid]      ||= 'E'
      product_spec = {
        'product' => {
          'description' => domain,
          'type' => 'domain'
        },
        'action' => {
          'name' => options[:action],
          :duration => options[:duration],
          'param' => {'tld_phase' => 'golive'}
        }
      }
      list = Gandi.client.call("catalog.list", Gandi.apikey, product_spec, options[:currency], options[:grid])
      if list.size == 1
        price = self.new
        price.action          = list.first['action']['name']
        price.description     = list.first['product']['description']
        return nil unless list.first['unit_price'].first
        price.price           = list.first['unit_price'].first['price']
        price.min_duration    = list.first['unit_price'].first['min_duration']
        price.max_duration    = list.first['unit_price'].first['max_duration']
        price.currency        = list.first['unit_price'].first['currency']
        price.grid            = list.first['unit_price'].first['grid']
        price.duration_unit   = list.first['unit_price'].first['duration_unit']
        price
      else
        nil
      end
    end
      
  end
end
