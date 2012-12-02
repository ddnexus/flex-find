module Flex
  module Find
    module Methods

      #    Scope methods. They returns a Scope object similar to AR.
      #    You can chain scopes, then you can call :count, :first, :all and :scan_all to get your result
      #    See Flex::Scope
      #
      #    scoped = MyModel.terms(:field_one => 'something', :field_two => nil)
      #                    .sort(:field_three => :desc)
      #                    .filters(:range => {:created_at => {:from => 2.days.ago, :to => Time.now})
      #                    .fields('field_one,field_two,field_three') # or [:field_one, :field_two, ...]
      #                    .params(:any => 'param')
      #
      #    # add another filter or other terms at any time
      #    scoped2 = scoped.terms(...).filters(...)
      #
      #    scoped2.count
      #    scoped2.first
      #    scoped2.all
      #    scoped2.scan_all {|batch| do_something_with_results batch}
      #
      Utils.define_delegation :to  => :scoped,
                              :in  => self,
                              :by  => :module_eval,
                              :for => Scope::METHODS


      # You can start with a non restricted Flex::Scope object
      def scoped
        @scoped ||= Scope[:context => flex.context]
      end


      #    define scopes as class methods
      #
      #  class MyModel
      #    include Flex::StoredModel
      #    ...
      #    scope :red, terms(:color => 'red').sort(:supplier => :asc)
      #    scope :size do |size|
      #      terms(:size => size)
      #    end
      #
      #    MyModel.size('large').first
      #    MyModel.red.all
      #    MyModel.size('small').red.all
      #
      def scope(name, scope=nil, &block)
        raise ArgumentError, "Dangerous scope name: a :#{name} method is already defined. Please, use another one." \
              if respond_to?(name)
        proc = case
               when block_given?
                 block
               when scope.is_a?(Scope)
                 lambda {scope}
               when scope.is_a?(Proc)
                 scope
               else
                 raise ArgumentError, "Scope object or Proc expected (got #{scope.inspect})"
               end
        metaclass = class << self; self end
        metaclass.send(:define_method, name) do |*args|
          scope = proc.call(*args)
          raise Scope::Error, "The scope :#{name} does not return a Flex::Scope object (got #{scope.inspect})" \
                unless scope.is_a?(Scope)
          scope
        end
        scopes << name
      end

    end
  end
end
