# Ottoman

Couchbase (> 2.0) ORM for Ruby on Rails 4.

## Installation

Add this line to your application's Gemfile:

    gem 'ottoman'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ottoman

## Usage

  Create a configuration file in `config/ottoman.yml`

  ```yaml
  development:
    host: localhost # default
    port: 8091      # default
    bucket: myapp_development
  test:
    bucket: myapp_test
  production:
    host: couchbase.myapp.com
    bucket: myapp_production
  ```

  Don't forget to __create the buckets__ on your Couchbase server/cluster.

  Then create a your models:

  `app/models/book.rb`

  ```ruby
  class Book < Ottoman::Model

    # define your attributes
    attribute  :title
    attributes :author, :year, :reference, :flags

    # validations
    validates_presence_of     :title, :author, :reference
    validates_numericality_of :year

    # this block is called to generate the record's id (remember it's a unique key in a key-value datastore)
    uuid do |book|
      "#{author}-#{title}".parameterize
    end

    # you can use active model callbacks too
    before_validation do |book|
      book.reference = Digest::MD5.hexdigest(book.title)
    end

  end
  ```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Licence

Copyright (c) 2013 Marca Tatem

MIT License

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
