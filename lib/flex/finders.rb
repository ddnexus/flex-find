module Flex
  module Finders

    class Error < StandardError; end

      def self.included(host_class)
        host_class.class_eval do
          extend Methods
          @scopes = []
          def self.scopes; @scopes end
        end
      end

  end
end

