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
contact.phone           = '+44.1202901101
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
