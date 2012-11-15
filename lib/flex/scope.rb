module Flex
  class Scope < Hash

    METHODS = [:terms, :filters, :sort, :fields, :size, :page, :params,
               :first, :last, :all, :scan_all, :count]

    class Error < StandardError; end

    include Structure::Mergeable

    # never instantiate this object directly: it is automatically done by the scoped method
    def initialize(proxy)
      if proxy.is_a?(Module)
        @host_class = proxy
        replace proxy.flex.variables
      else
        @host_class = proxy.host_class
        replace proxy.variables
      end
    end

    # accepts also :any_term => nil for missing values
    def terms(value)
      terms, missing_fields = {}, []
      value.each { |f, v| v.nil? ? missing_fields.push({ :missing => f }) : (terms[f] = v) }
      deep_merge :terms => terms, :_missing_fields => missing_fields
    end

    # accepts one or an array or a list of filter structures
    def filters(*value)
      deep_merge :filters => array_value(value)
    end

    # accepts one or an array or a list of sort structures documented at
    # http://www.elasticsearch.org/guide/reference/api/search/sort.html
    # doesn't probably support the multiple hash form, but you can pass an hash as single argument
    # or an array or list of hashes
    def sort(*value)
      deep_merge :sort => array_value(value)
    end

    # the fields that you want to retrieve (limiting the size of the response)
    # the returned records will be frozen, and the missing fileds will be nil
    # pass an array eg fields.([:field_one, :field_two])
    # or a list of fields e.g. fields(:field_one, :field_two)
    def fields(*value)
      deep_merge :params => {:fields => array_value(value)}
    end

    # limits the resize of the retrieved hits
    def size(value)
      deep_merge :params => {:size => value}
    end

    # sets the :from param so it will return the nth page of size :size
    def page(value)
      deep_merge :params => {:page => value||1}
    end

    # the standard :params variable
    def params(value)
      deep_merge :params => value
    end

    def find(id_or_ids)
      @host_class.find id_or_ids, self
    end

    # it limits the size of the query to the first document and returns it as a single document object
    def first(vars={})
      variables = params(:size => 1).deep_merge(vars)
      Find.with_scope(variables).first
    end

    # it limits the size of the query to the last document and returns it as a single document object
    def last(vars={})
      variables = params(:from => count-1, :size => 1).deep_merge(vars)
      Find.with_scope(variables).first
    end

    # will retrieve all documents, the results will be limited by the default :size param
    # use #scan_all if you want to really retrieve all documents (in batches)
    def all(vars={})
      variables = deep_merge(vars)
      Find.with_scope variables
    end

    # scan_search: the block will be yielded many times with an array of batched results.
    # You can pass :scroll and :size as params in order to control the action.
    # See http://www.elasticsearch.org/guide/reference/api/search/scroll.html
    def scan_all(vars={}, &block)
      variables = deep_merge(vars)
      Find.flex.scan_search(:with_scope, variables, &block)
    end

    # performs a count search on the scope
    def count(vars={})
      result = Find.with_scope params(:search_type => 'count').deep_merge(vars)
      result['hits']['total']
    end

    def inspect
      "#<#{self.class.name} #{self}>"
    end

    def respond_to?(meth, private=false)
      super || @host_class.flex.scopes.include?(meth.to_sym)
    end

    def method_missing(meth, *args, &block)
      super unless respond_to?(meth)
      deep_merge @host_class.send(meth, *args)
    end

    private

    def array_value(value)
      value.first if value.first.is_a?(Array) && value.size == 1
    end

  end
end
