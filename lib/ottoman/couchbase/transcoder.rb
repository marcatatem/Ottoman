module Couchbase
  module Transcoder
    module Document

      # Monkey patching the couchbase gem load method to force strict mode and symbolization of keys
      def self.load blob, flags, options = {}
        if (flags & Bucket::FMT_MASK) == Bucket::FMT_DOCUMENT || options[:forced]
          MultiJson.load( blob, { adapter: :oj, symbolize_keys: true, mode: :strict })
        else
          if Compat.enabled?
            return Compat.guess_and_load blob, flags, options
          else
            raise ArgumentError,
              "unexpected flags (0x%02x instead of 0x%02x)" % [flags, Bucket::FMT_DOCUMENT]
          end
        end
      end

    end
  end
end