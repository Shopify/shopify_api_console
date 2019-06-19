[![Build Status](https://travis-ci.org/Shopify/shopify_api_console.svg?branch=master)](https://travis-ci.org/Shopify/shopify_api_console)


# This gem has been renamed

#### If you're looking for the [Shopify App CLI](https://github.com/Shopify/shopify-app-cli/) you can find it [here](https://github.com/Shopify/shopify-app-cli/).

* Name: shopify_cli --> shopify_api_console
* GitHub: https://github.com/Shopify/shopify_cli --> https://github.com/Shopify/shopify_api_console
* RubyGems: https://rubygems.org/gems/shopify_cli --> https://rubygems.org/gems/shopify_api_console

shopify_cli 1.x will not be supported going forward. v1.0.3+ will produce a deprecation warning.

Starting with v2.0, the gem has been renamed to `shopify_api_console`. We recommend switching to shopify_api_console v2.0+ as soon as possible.

1.x versions will continue to exist on [RubyGems](https://rubygems.org/gems/shopify_cli) and in the [GitHub releases](https://github.com/Shopify/shopify_cli/releases). If you _must_ use one of these releases, make sure to specify a version:

```
gem install shopify_cli -v v1.0.4
```

# Shopify API Console for Ruby

This package includes the ``shopify-api`` executable to make it easy to open up an interactive console to use the Admin API with a shop.

```sh
gem install shopify_api_console
```

## Usage

See the documentation at https://help.shopify.com/en/api/guides/using-the-api-console

## Getting started

1. Obtain a private API key and password to use with your shop (step 2 in "Getting Started")

2. Use the ``shopify-api`` script to save the credentials for the shop to quickly log in.

   ```bash
   shopify-api add yourshopname
   ```

   Follow the prompts for the shop domain, API key and password.

3. Start the console for the connection.

   ```bash
   shopify-api console
   ```

   ```bash
   shopify-api help
   ```

## Contributing

After checking out the source, run:

  `$ bundle install && bundle exec rake test`
