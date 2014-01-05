# Gandi API Library

This is a short library to facilitate working with the Gandi API for
domain registrations. While there are other libraries for this purpose
this offers a more satisfying syntax.

## Installation

As usual, just pop a reference to the gem into your `Gemfile` and run
`bundle`. Alternatively, just install the gem and require it manually.

```ruby
gem 'viaduct-gandi', :require => 'gandi'
```

## Configuration

Before you can run commands, you'll need to configure the library.

```ruby
Gandi.apikey = 'abc123abc123abc123abc'
Gandi.mode   = 'test' # or 'live' 
```

## Pricing

You can obtain pricing for registrations very easily. This example is the 
most basic form of obtaining a price. In this instance, it returns the price
for registering a .com domain.

```ruby
price = Gandi::Price.find('example.com')
price.action          #=> 'create'
price.description     #=> '.com'
price.price           #=> 5.5
price.min_duration    #=> 1
price.max_duration    #=> 10
price.currency        #=> 'GBP'
price.grid            #=> 'E'
price.duration_unit   #=> 'y'
```

There are a number of options which can be passed to method.

* `:action` - which service you will be using (create, renew, restore, transfer, plus others - create is default)
* `:currency` - which currency to return a price in (GBP, EUR or USD - GBP is default)
* `:grid` - your pricing grid (A,B,C,D,E - E is default)
* `:duration` - the duration of the registration (a positive interger - 1 is default)

## Contacts

At the root of all domain registrations is a contact. Each contact has a unique `handle`
which identifies the contact and is needed for all registrations.

### Creating a new contact

```ruby
contact = Gandi::Contact.new
contact.type            = 0
contact.first_name      = 'Adam'
contact.last_name       = 'Cooke'
contact.address         = 'Unit 9 Winchester Place'
contact.city            = 'Poole'
contact.country         = 'GB'
contact.email_address   = 'adam@example.com'
contact.phone           = '+44.1202901101'
contact.password        = 'randompasswordhere'
contact.save            #=> true
contact.handle          #=> 'AC1234-GANDI'
```

If an error occurs here there are two possible exceptions which may be raised (as the
same applies to updates). If a validation error is caught locally you will find a 
`Gandi::ValidationError` is raised otherwise you'll receive `Gandi::DataError` with some
mostly uninteligiable garbage from the Gandi API.

### Finding a contact

```ruby
contact = Gandi::Contact.find('AC1234')
contact.first_name      #=> 'Adam'
```

### Updating a contact

To update a contact you need to find it and then make changes to its attributes followed
by a save operation.

```ruby
contact = Gandi::Contact.find('AC1234')
contact.phone = '+44.123451234'
contact.save
```

### Determine if a contact can be associated with a domain

If you wish to see whether a contact is suitable for registration with a given domain,
you can call this method on any contact.

```ruby
contact.can_associate?('yourdomain.com')
```

This will return true or an error string straight from the Gandi API.

### Return associated domains

If you wish to return all domains associated with a contact, you can call the `domains`
method.

```ruby
contact.domains     #=> [Gandi::Domain, Gandi::Domains, ...]
```

## Domains

Once you have some contacts, you can easily manage domains through through the library.

### TLDs

You can get a full list of TLDs which can be registered using the Gandi API using the method
shown below. This will return an array of hashes with TLD information.

```ruby
Gandi::Domains.tlds
```

### Checking domain availability

Gandi provides a asyncronous method for checking domain availability. This library provides
methods for determining availability both asyncronously and syncronously.

The asyncronous method accepts a number of domains to check and will return a hash
of domains with their availability status. Any status which is 'pending' has not been determined
yet and another call should be made in the near future to check again.

```ruby
Gandi::Domain.check_availability('domain1.com', 'domain2.io')   #=> {'domain1.com' => 'pending', 'domain2.io' => 'pending'}
```

The syncronous method will keep calling the API until it gets a non-pending status for all
requested domains. Pending will only be returned if the status cannot be determined within
20 requests to the Gandi API.

```ruby
Gandi::Domain.check_availability!('domain1.com', 'domain2.io')   #=> {'domain1.com' => 'unavailable', 'domain2.io' => 'available'}
```

In addition to these methods, there is also a shorthand syncronous method for checking a
single domain's status.

```ruby
Gandi::Domain.available?('blahblahblah.com')    #=> true or false
```

### Create/register a new domain

In order to register a domain you need to create a new domain registration object. Once
created the domain will be set up automatically. You should monitor the operation's 'step'
attribute to see how things are progressing. When this is 'DONE', the domain has been
registered.

```ruby
if Gandi::Domain.available?('somedomain.com')
  # Create a domain registration request
  operation = Gandi::Domain.create('blahblahblah.com', :owner => 'ABC123')
  # Monitor the operation status
  operation.step          #=> 'BILL'
  operation.reload
  operation.step          #=> 'RUN'
  operation.reload
  operation.step          #=> 'DONE' or 'ERROR'
  operation.last_error    #=> 'An error message here if failed'
else
  # Domain is not available for registration
end
```

### Looking up domain information

Once a domain has been registered, you can look it up using the following method.

```ruby
domain = Gandi::Domain.find('blahblahblah.com')
domain.name       #=> "blahblahblah.com"
domain.owner      #=> A Gandi::Contact instance for the owner\
domain.partial?   #=> false
```

In addition to these methods, there are a number of other attributes which are available.
Consult with the [Gandi docs](http://doc.rpc.gandi.net/domain/reference.html#DomainReturn) 
for full details.

### Changing contacts

To change the contact associated with a domain you can use the method below. You must
pass the Gandi handle for the new contact. 

```ruby
domain = Gandi::Domain.find('blahblahblah.com')
operation = domain.change_contacts('admin' => 'DEF123', 'bill' => 'DEF123', 'tech' => 'DEF123')
```

Note: you cannot change the owner with this method and you don't need to change all
the contact types. You should monitor the operation object to determine the status.

### Renewing a domain

If you wish to renew a domain, you can use the method below.

```ruby
domain = Gandi::Domain.find('blahblahblah.com')
operation = domain.renew(2015, 2)
```

The first argument here is the current expiry year and the second argument is the duration
for the renewal. You should monitor the operation object to determine the status.

### Restoring a domain

If you wish to restore a domain, you can use the method below.

```ruby
domain = Gandi::Domain.find('blahblahblah.com')
operation = domain.restore(2)
```

The first argument here is the duration you wish to renew the domain for.
You should monitor the operation object to determine the status.
