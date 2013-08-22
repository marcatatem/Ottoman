module Ottoman
  
  class Railtie < Rails::Railtie

    initializer "Load configuration file and connect to Couchbase" do
      load_configuration_file_and_connect
    end

    protected
      
      def load_configuration_file_and_connect
        Ottoman.connect(YAML.load(File.open(File.join(Rails.root,'config','ottoman.yml')))[Rails.env].deep_symbolize_keys)
      end

  end

end