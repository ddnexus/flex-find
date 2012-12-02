module Flex
  module Find
    module Scope

      extend self
      include Loader
      flex.load_source File.expand_path('../scope.yml', __FILE__)

    end
  end
end
