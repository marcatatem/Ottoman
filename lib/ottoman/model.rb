module Ottoman
  class Model
    
    # enable active model methods and callbacks
    include ActiveModel::Model
    extend  ActiveModel::Callbacks

    # representation methods
    include Ottoman::Representation
    
    # uuid and attribute list
    @@_uuid = lambda{}
    @@_attributes = []

    # internal references
    attr_accessor :_cas, :_id

    # available callbacks
    define_model_callbacks :validation, :create, :update, :save

    # attributes
    def self.attribute *names
      names.each{ |name| @@_attributes << name }
      class_eval{ attr_accessor *names }
    end
    class << self; alias :attributes :attribute; end

    def attributes
      @@_attributes
    end

    # uuid generator
    def self.uuid &block
      @@_uuid = block
    end

    # object creation
    def self.create data
      self.new(data).save
    end

    # state
    def persisted?
      !new_record?
    end

    def new_record?
      @_id.blank?
    end

    def id
      @_id.split(':').last
    end

    # validations
    def run_validations
      run_callbacks :validation do
        valid?
      end
    end

    # save record
    def save
      return false unless run_validations
      create_or_update
    end

    def create_or_update
      new_record? ? create_record : update_record
    end

    def create_record
      run_callbacks :create do
        uuid = self.instance_eval(&@@_uuid)
        @_cas = Ottoman.client.add "#{self.class.name.tableize}:#{uuid}", self.to_hash
        @_id  = uuid
        self
      end
    end

    def update_record
      run_callbacks :update do
        @_cas = Ottoman.client.update "#{self.class.name.tableize}:#{self.id}", self.to_hash, cas: @_cas
        self
      end
    end

    # fetch record
    def self.fetch *uuid
      r = []
      Ottoman.client.get(uuid.to_a.map{|x|"#{self.name.tableize}:#{x}"}).each_pair do |k, v|
        if v[0].is_a?(Hash)
          instance = new(v[0].extract!(*@@_attributes))
          instance._cas = v[2]
          instance._id = k
          r << instance
        end
      end
      r.empty? ? nil : r.length == 1 ? r[0] : r
    end

    # update record
    def update_attribute attribute, value
      public_send("#{attribute}=", value)
      save
    end

    def update_attributes attributes
      return if attributes.blank?
      attributes.stringify_keys.each_pair do |attribute, value|
        public_send("#{attribute}=", value)
      end
      save
    end

    # delete record
    def delete force: false
      Ottoman.client.delete("#{self.class.name.tableize}:#{self.id}", cas: force ? nil : @_cas) unless new_record? or @_cas.blank?
      freeze
    end

  end
end