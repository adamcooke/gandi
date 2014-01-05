module Gandi
  class Domain
    
    class << self
      
      #
      # Return all available TLDs
      #
      def tlds
        Gandi.call('domain.tld.list')
      end
      
      #
      # Check the availability of a set of domains
      #
      def check_availability(*domains)
        Gandi.call('domain.available', domains)
      end
      
      #
      # Check the availability of a set of domains syncronously
      #
      def check_availability!(*domains)
        max_checks = 10
        loop do
          result = check_availability(*domains)
          return result if result.all? { |k,v| v != 'pending' }
          max_checks -= 1
          return result if max_checks <= 0
          sleep 0.7
        end
      end
      
      #
      # Check the availability of a given domain
      #
      def available?(domain, max_checks = 10)
        loop do
          result = check_availability(domain)
          return result[domain] == 'available' unless result[domain] == 'pending'
          max_checks -= 1
          return false if max_checks <= 0
          sleep 0.7
        end
      end
      
      #
      # Return the total number of domains on the account
      #
      def count
        Gandi.call('domain.count')
      end
      
      #
      # Register a domain for the given contact. This is a billable action
      # so be cautious. This method will return an operation object as this
      # is not run straight away.
      #
      def create(domain, options = {})
        raise ValidationError, "You must specify 'owner' as an option" unless options[:owner]
        spec = {}
        spec['duration']      = options[:duration] || 1
        spec['owner']         = options[:owner]
        spec['admin']         = options[:admin] || options[:owner]
        spec['bill']          = options[:bill]  || options[:owner]
        spec['tech']          = options[:tech]  || options[:owner]
        spec['nameservers']   = options[:nameservers] if options[:nameservers]
        spec['zone_id']       = options[:zone_id] if options[:zone_id]
        result = Gandi.call('domain.create', domain, spec)
        Operation.new(result)
      end
      
      #
      # Return information about a doman
      #
      def find(name)
        self.new(Gandi.call('domain.info', name))
      end
      
      #
      # Return an array of all domains
      #
      def list
        Gandi.call('domain.list').map { |d| self.new(d, true) }
      end
      
    end
    
    def initialize(attributes, partial = false)
      @attributes = attributes
      @partial = partial
    end
    
    def partial?
      @partial
    end
    
    def to_s
      "#<Gandi::Domain #{name}>"
    end
    
    #
    # Return the domain name
    #
    def name
      @attributes['fqdn']
    end
    
    #
    # Return attributes
    #
    def method_missing(name, value = nil)
      if @attributes.keys.include?(name.to_s)
        @attributes[name.to_s]
      else
        super
      end
    end
    
    #
    # Get all the latest information about the domain
    #
    def reload
      @attributes = Gandi.call('domain.info', name)
      self
    end
    
    #
    # Return the domain's owner object
    #
    def owner
      @owner ||= Gandi::Contact.find(contacts['owner']['handle'])
    end
    
    #
    # Change the domains. Accepts a hash
    #
    def change_contacts(hash)
      Operation.new(Gandi.call('domain.contacts.set', name, hash))
    end
    
    #
    # Renew the domain
    #
    def renew(current_year, duration = 1)
      Operation.new(Gandi.call('domain.renew', name, 'current_year' => current_year, 'duration' => duration))
    end
    
    #
    # Restore the domain
    #
    def restore(duration = 1)
      Operation.new(Gandi.call('domain.restore', name, 'duration' => duration))
    end
    
  end
end
