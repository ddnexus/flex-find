module Flex
  module Find

    extend self
    include Loader
    flex.load_search_source File.expand_path('../finders/source.yml', __FILE__)

    include Finders::Inline

    # delegates to :with_scope template
    def with_scope(*args)
      flex.with_scope *args
    end

  end
end
