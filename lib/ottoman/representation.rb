module Ottoman
  module Representation

    def inspect
      "#<#{self.class.name} id: #{object_representation(self.id)}, #{hash_representation(self.to_hash)}>"
    end

    def to_hash
      pairs = {}
      attributes.each do |attribute|
        pairs[attribute] = send(attribute)
      end
      pairs
    end; alias :to_h :to_hash

    protected

      def hash_representation hash
        tuple = []
        hash.each_pair do |attribute, value|
          tuple << "#{attribute}: #{object_representation(value)}"
        end
        tuple.join(', ')
      end

      def array_representation array
        array.collect do |value|
          object_representation(value)
        end.join(', ')
      end

      def object_representation object
        case object
        when String
          %Q/"#{object}"/
        when Array
          %Q/[#{array_representation(object)}]/
        when Hash
          %Q/{#{hash_representation(object)}}/
        when NilClass
          %Q/nil/
        else
          object.to_s
        end
      end

  end
end