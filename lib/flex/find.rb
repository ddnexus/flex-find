module Flex
  module Find

    extend self
    include Loader
    flex.load_search_source File.expand_path('../finders/source.yml', __FILE__)

  end
end
