module Gandi
  class Operation
    
    def self.find(id)
      self.new(Gandi.call('operation.info', id))
    end
    
    def initialize(attributes)
      @attributes = attributes
    end
        
    
    def method_missing(name, value = nil)
      if @attributes.keys.include?(name.to_s)
        @attributes[name.to_s]
      else
        super
      end
    end
    
    def reload
      @attributes = Gandi.call('operation.info', @attributes['id'])
      self
    end
    
  end
end
