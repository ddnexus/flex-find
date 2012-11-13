module Flex
  module Finders

    class Error < StandardError; end

    # includes the finders in the host_class.flex object
    def self.included(host_class)
      Finders.init(host_class)
      host_class.flex.instance_eval do
        extend Methods
        def flex; self end
      end
    end

    module Inline
      # includes the finders in the host_class itself
      def self.included(host_class)
        host_class.extend Methods
        Finders.send(:init, host_class)
      end
    end

  private

    def self.init(host_class)
      host_class.flex.instance_eval do
        @scopes = []
        def scopes; @scopes end
      end
    end

  end
end

