# Shopify API Console for Ruby

[![Build Status](https://travis-ci.org/Shopify/shopify_api_console.svg?branch=master)](https://travis-ci.org/Shopify/shopify_api_console)

# ⚠️ Important: This gem has been renamed

#### If you're looking for **Shopify CLI**, refer to the [official docs](https://shopify.dev/apps/tools/cli) or [contribute on GitHub](https://github.com/Shopify/shopify-cli/).

* Name: shopify_cli --> shopify_api_console
* GitHub: https://github.com/Shopify/shopify_cli --> https://github.com/Shopify/shopify_api_console
* RubyGems: https://rubygems.org/gems/shopify_cli --> https://rubygems.org/gems/shopify_api_console

shopify_cli 1.x will not be supported going forward. v1.0.3+ will produce a deprecation warning.

Starting with v2.0, the gem has been renamed to `shopify_api_console`. We recommend switching to shopify_api_console v2.0+ as soon as possible.

1.x versions will continue to exist on [RubyGems](https://rubygems.org/gems/shopify_cli) and in the [GitHub releases](https://github.com/Shopify/shopify_cli/releases). If you _must_ use one of these releases, make sure to specify a version:

```sh
gem install shopify_cli -v v1.0.4
```
----
## Getting started

This tutorial will get you started using the Shopify API console in development.

### Requirements

Before you begin using the console, you'll need a few things:

- A [Shopify Partner account](https://www.shopify.com/partners)
- A development store
- An API key for a private app
- The [Shopify API Ruby gem](https://github.com/Shopify/shopify_api)
- The [Shopify API Console for Ruby](https://github.com/Shopify/shopify_api_console/)

### Set up your development store

To become a Shopify Partner, [sign up for a free Shopify Partner account](https://www.shopify.com/partners).

As a Shopify Partner, you gain access to the [Partner Dashboard](https://partners.shopify.com/organizations). From the Partner Dashboard, you can [create a development store](https://shopify.dev/apps/tools/development-stores).

Open up your development store and populate it with orders, customers, products — whatever you might need to properly develop your app.

### Create an API key for a private app

To access the Shopify API console, you need to create a dedicated private app in your development store with the permissions required to access resources. You'll use this private app's API credentials when setting up your Shopify API Console Ruby gem. Creating the private app generates its API key and password.

Learn more about [creating API keys for private apps](https://shopify.dev/apps/auth/basic-http).

### Install the required gems

After you've set up your development store, created the private app, and have your API key, install the [Shopify API](https://github.com/Shopify/shopify_api) and [Shopify API Console](https://github.com/Shopify/shopify_api_console/) Ruby gems.

```sh
gem install shopify_api shopify_api_console
```

## Using the console

Open up your terminal, and type `shopify-api`.

```sh
$ shopify-api
Commands:
  shopify-api add CONNECTION        # create a config file for a connection named...
  shopify-api console [CONNECTION]  # start an API console for CONNECTION
  shopify-api default [CONNECTION]  # show the default connection, or make CONNEC...
  shopify-api edit [CONNECTION]     # open the config file for CONNECTION with yo...
  shopify-api help [COMMAND]        # Describe available commands or one specific...
  shopify-api list                  # list available connections
  shopify-api remove CONNECTION     # remove the config file for CONNECTION
  shopify-api show [CONNECTION]     # output the location and contents of the CON...
```

You’re presented with options for setting up and managing connection configuration. Nothing is set up yet, so start by adding a connection. Name it whatever you like, but make sure that the URL matches up with that of your development store. You’ll be prompted to enter in your API key and password. Be sure to enter the API password, not secret.
To learn more about Shopify API release schedule to find the API version, please read [Shopify API Versioning](https://shopify.dev/api/usage/versioning)

```sh
$ shopify-api add myshopifystore
Domain? (leave blank for myshopifystore.myshopify.com) myshopifystore.myshopify.com
open https://myshopifystore.myshopify.com/admin/apps/private in your browser to get API credentials
API key? [REDACTED]
Password? [REDACTED]
API version? Leave blank for the latest version
create  .shopify/shops/myshopifystore.yml
remove  .shopify/shops/default
Default connection is myshopifystore
```

Now, start the console. Type `shopify-api console`:

```sh
$ shopify-api console
using myshopifystore.myshopify.com
```

To make things easier, you can include the `ShopifyAPI` module provided by the Shopify API gem right away. This is optional, but if you leave it off, you’ll need to prefix API calls with `ShopifyAPI::`.

```sh
> include ShopifyAPI
```

Now you can start to query the API and look at data from your store. Check out the [API docs](https://shopify.dev/api/admin) to see what is queryable and mutable.

To get a list of products, type `Product.all`:

```ruby
> Product.all
```

Try mutating some data; add a customer with the following values:

```ruby
{
  first_name: 'Firstname',
  last_name: 'Lastname',
  email: 'firstname.lastname@shopify.com',
  addresses: [
    {
      address1: '123 Fake St',
      city: 'Townsville',
      province: 'ON',
      phone: '555-1212',
      zip: '123ABC',
      last_name: 'Lastname',
      first_name: 'Firstname',
      country: 'CA'
    }
  ],
  send_email_invite: true
}
```

```ruby
> i = ShopifyAPI::Customer.new({first_name: 'Firstname', last_name: 'Lastname', email: 'firstname.lastname@shopify.com', addresses: [{ address1: '123 Fake St', city: 'Townsville',  province: 'ON', phone: '555-1212', zip: '123ABC', last_name: 'Lastname', first_name: 'Firstname', country: 'CA' }], send_email_invite: true })
> i.save
 => true
```

Don’t forget to save the entry!

You’ve now successfully added a customer to your dev store, and sent them an email invitation.

## More complex calls

### Get a list of resources using query parameters

Find all of a given resource type (e.g. Products, Customers, etc.), using the `limit` parameter to limit the results:

```ruby
> Product.find(:all, :params => {:limit => 3})
```

### Update a resource

Add a description to an existing resource:

```ruby
> i = CustomCollection.find(7724148)
 => #<ShopifyAPI::CustomCollection:0x007fd47c57acf8 @attributes={"body_html"=>nil, "handle"=>"frontpage", "id"=>7724148, "published_at"=>2012-07-06 17:57:28 UTC, "sort_order"=>"alpha-asc", "template_suffix"=>nil, "title"=>"Frontpage", "updated_at"=>2013-01-31 21:55:21 UTC}, @prefix_options={}>
> i.body_html = 'Give the collection a new description'
 => "Give the collection a new description"
> i.save
 => true
> CustomCollection.find(7724148)
 => #<ShopifyAPI::CustomCollection:0x007fd47c5f1ba0 @attributes={"body_html"=>"Give the collection a new description", "handle"=>"frontpage", "id"=>7724148, "published_at"=>2012-07-06 17:57:28 UTC, "sort_order"=>"alpha-asc", "template_suffix"=>nil, "title"=>"Frontpage", "updated_at"=>2013-02-26 04:21:41 UTC}, @prefix_options={}>
```

## Troubleshooting

By making a small change to the earlier example, you can see how to troubleshoot errors. Change the entry slightly to set a password instead of sending an email invite, and then save the entry.

```ruby
{
  first_name: 'Firstname',
  last_name: 'Lastname',
  email: 'firstname.lastname@shopify.com',
  addresses: [
    {
      address1: '123 Fake St',
      city: 'Townsville',
      province: 'ON',
      phone: '555-1212',
      zip: '123ABC',
      last_name: 'Lastname',
      first_name: 'Firstname',
      country: 'CA'
    }
  ],
  password: '1234',
  password_confirmation: '1234'
}
```

Trying to save this data fails:

```ruby
> i.save
 => false
```

Type `i.errors` to find out why. You’ll get some information back on what you tried to POST, and some information on the error:

```ruby
@remote_errors=#<ActiveResource::ResourceInvalid: Failed.  Response code = 422.  Response message = Unprocessable Entity.>, @validation_context=nil, @errors=#<ActiveResource::Errors:0x007fc814173b60 ...>>, @messages={:password=>["is too short (minimum is 5 characters)"], :email=>["has already been taken"]
```

It didn’t work because the password is too short, and the email address is already registered to the first customer you created. You’ve just quickly and easily debugged why an API call wasn’t working!

## Contributing

After checking out the source, run:

`$ bundle install && bundle exec rake test`
