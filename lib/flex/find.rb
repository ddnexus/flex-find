module Flex
  module Find

    class Error < StandardError; end

    def self.included(context)
      context.class_eval do
        @flex ||= ClassProxy::Base.new(context)
        @flex.extend(ClassProxy::IndexType) # used to add index and type to Loader only classes
        def self.flex; @flex end

        extend Methods
        @scopes = []
        def self.scopes; @scopes end
      end
    end

  end
end

