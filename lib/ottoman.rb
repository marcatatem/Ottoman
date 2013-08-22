require "oj"
require "active_model"
require "yaml"
require "couchbase"

require "ottoman/version"
require "ottoman/datastore"
require "ottoman/representation"
require "ottoman/model"
require "ottoman/couchbase/transcoder"

require 'ottoman/railtie' if defined?(Rails)

#require 'ruby-prof'

module Ottoman
  
  @@client = nil

  def self.connect parameters = {}
    @@client = Datastore.new(parameters)
  end

  def self.client
    @@client
  end


end

