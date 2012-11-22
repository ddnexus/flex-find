module Flex
  module Find
    module With

      extend self
      include Loader
      flex.load_search_source File.expand_path('../source.yml', __FILE__)

    end
  end
end
