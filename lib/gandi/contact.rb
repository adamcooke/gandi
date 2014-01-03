module Gandi
  class Contact
    
    COUNTRIES = ['AF','ZA','AL','DZ','DE','AD','AO','AI','AG','AN','SA','AR','AM','AW','AC','AU','AT','AZ','BS','BH','BD','BB','BY','BE','BZ','BJ','BM','BT','BO','BA','BW','BR','BN','BG','BF','BI','KH','CM','CA','CV','KY','CF','CL','CN','CY','CO','KM','CG','CD','CK','KR','KP','CR','CI','HR','CU','DK','DJ','DO','DM','EG','SV','AE','EC','ER','ES','EE','US','ET','FK','FO','FJ','FI','FR','GA','GM','GE','GH','GI','GR','GD','GL','GU','GT','GN','GQ','GW','GY','HT','HI','HN','HK','HU','IN','ID','IR','IQ','IE','IS','IL','IT','JM','JP','JE','JO','KZ','KE','KG','KI','KW','LA','LS','LV','LB','LR','LY','LI','LT','LU','MO','MK','MG','MY','MW','MV','ML','MT','MP','MA','MH','MU','MR','MX','FM','MD','MC','MN','MS','MZ','MM','NA','NR','NP','NI','NE','NG','NU','NF','NO','NZ','OM','UG','UZ','PK','PW','PS','PA','PG','PY','NL','PE','PH','PL','PT','PR','QA','RO','GB','RU','RW','SH','LC','KN','SM','VC','SB','AS','WS','ST','SN','SC','SL','SG','SK','SI','SO','SD','LK','SE','CH','SR','SZ','SY','TJ','TW','TZ','TD','CZ','TH','TP','TG','TK','TO','TT','TN','TM','TC','TR','TV','UA','UY','VU','VE','VI','VG','VN','YE','ZM','ZW','RE','PF','AQ','GF','NC','MQ','GP','PM','TF','YT','RS','TL','CC','CX','HM','AX','BV','GS','GG','IM','ME','IO','PN','EH','BL','MF','VA','SJ','WF','EP']
    TYPES = {0 => 'person', 1 => 'company', 2 => 'association', 3 => 'public_body'}
    ATTRIBUTE_MAP = {
      'type'              => 'type',
      'given'             => 'first_name',
      'family'            => 'last_name',
      'orgname'           => 'organization',
      'password'          => 'password',
      'streetaddr'        => 'address',
      'city'              => 'city',
      'zip'               => 'post_code',
      'country'           => 'country',
      'email'             => 'email_address',
      'phone'             => 'phone',
      'extra_parameters'  => 'extra_parameters'
    }
    
    # Type of object
    attr_reader :handle
    attr_reader :attributes
    attr_accessor :type
    
    # Name
    attr_accessor :first_name
    attr_accessor :last_name
    attr_accessor :organization
    
    # Credentials
    attr_accessor :password
    
    # Address Fields
    attr_accessor :address
    attr_accessor :city
    attr_accessor :post_code
    attr_accessor :country
    
    # Contact details
    attr_accessor :email_address
    attr_accessor :phone
    attr_accessor :extra_parameters
    
    def initialize
      @attributes = {}
    end
    
    #
    # Find a contact based on it's handle
    #
    def self.find(handle)
      info = Gandi.client.call("contact.info", Gandi.apikey, handle)
      contact = self.new
      contact.set_attributes(info)
      contact
    end
    
    #
    # Return extra parameters for this contact
    #
    def extra_parameters
      @extra_parameters ||= {}
    end
    
    #
    # Save the contact's information
    #
    def save
      new_record? ? create : update
    end
     
    #
    # Is this a new record?
    #   
    def new_record?
      self.handle.nil?
    end

    # 
    # Create a contact
    #
    def create
      return false unless new_record?
      raise Gandi::ValidationError, self.errors unless self.errors.empty?
      result = Gandi.call('contact.create', dirty_attributes_with_remote_keys)
      set_attributes(result)
      true
    end
    
    #
    # Update a contact
    #
    def update
      return false if new_record?
      raise Gandi::ValidationError, self.errors unless self.errors.empty?
      result = Gandi.call('contact.update', self.handle, dirty_attributes_with_remote_keys)
      set_attributes(result)
      true
    end
    
    #
    # Is the current instance dirty? (I.e. need updating remotely)
    #
    def dirty?
      dirty_attributes.empty?
    end
    
    #
    # Returns a hash of all dirty attributes (with local keys)
    #
    def dirty_attributes
      ATTRIBUTE_MAP.values.inject(Hash.new) do |hash, local|
        if @attributes.keys.include?(local) && @attributes[local] == self.send(local)
          next hash
        else
          hash[local] = self.send(local)
        end
        hash
      end
    end
    
    #
    # Returns a hash of all dirty_attributes (with remote keys)
    #
    def dirty_attributes_with_remote_keys
      dirty_attributes.inject(Hash.new) do |hash, (local, value)|
        remote = ATTRIBUTE_MAP.select { |k,v| v == local }.first[0]
        hash[remote] = value || ''
        hash
      end
    end
    
    #
    # Set the attributes from a remote hash
    #
    def set_attributes(hash)
      @handle = hash['handle']
      @attributes = {}
      ATTRIBUTE_MAP.each do |remote, local|
        self.send(local + '=', hash[remote])
        remote_value = hash[remote]
        remote_value = remote_value.dup if remote_value && !remote_value.is_a?(Fixnum)
        @attributes[local] = remote_value
      end
    end
    
    #
    # Validate the contact looks OK to avoid getting ugly-ass and unhelpful messages
    # from the Gandi endpoint.
    # 
    # Returns an array of problems or empty if no issues.
    #
    def errors
      Hash.new.tap do |a|
        a[:type] = "must be one of #{TYPES.keys.join(',')}" unless TYPES.keys.include?(self.type)
        a[:city]          = 'is required'   if is_blank?(self.city)
        a[:first_name]    = 'is required'   if is_blank?(self.first_name)
        a[:last_name]     = 'is required'   if is_blank?(self.last_name)
        a[:organization]  = 'is required'   if is_blank?(self.organization) && [1,2,3].include?(self.type)
        a[:country]       = 'is invalid'    unless COUNTRIES.include?(self.country)
        a[:address]       = 'is required'   if is_blank?(self.address)
        a[:phone]         = 'is invalid'    unless self.phone =~ /^\+\d{1,3}\.\d+$/
        a[:password]      = 'is required'   if is_blank?(self.password) && new_record?
        a[:email_address] = 'is invalid'    unless self.email_address =~ /^(([a-z0-9_\.\+\-\=\?\^\#]){1,64}\@(([a-z0-9\-]){1,251}\.){1,252}[-a-z0-9]{2,63})$/
      end
    end
    
    #
    # Is the given variable blank?
    #
    def is_blank?(variable)
      variable.nil? || variable.length == 0
    end
    
  end
end
