module Ottoman
  class Datastore

    attr_accessor :client

    def initialize parameters
      self.connect parameters
    end

    def get keys
      @client.get keys, { format: :document, extended: true, quiet: true }
    end

    def set key, value, **options
      @client.set key, value, { format: :document }.merge(options)
    end

    def add key, value, **options
      @client.add key, value, { format: :document }.merge(options)
    end

    def update key, value, **options
      @client.replace key, value, { format: :document }.merge(options)
    end

    def delete key, cas: nil
      @client.delete key, { cas: cas }
    end

    def exists? key
      begin
        @client.touch key
      rescue Couchbase::Error::NotFound => err
        false
      end
    end

    protected

      def connect parameters
        # authentication
        authentication = unless ( password = ENV['COUCHBASE_PASSWORD'] rescue nil ).blank?
          { username: parameters.fetch(:bucket, 'default'),
            password: password }
        else {} end
        # connection
        @client = Couchbase.connect({
          bucket: 'default'
        }.merge( parameters ).merge( authentication ))
      end; alias :reconnect! :connect

  end
end