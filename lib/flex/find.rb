module Flex
  module Find

    class Error < StandardError; end

    def self.included(host_class)
      host_class.class_eval do
        @flex ||= ClassProxy::Base.new(host_class)
        def self.flex; @flex end

        extend Methods
        @scopes = []
        def self.scopes; @scopes end
      end
    end

  end
end

