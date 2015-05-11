require 'facets/hash/deep_rekey'
require 'facets/pathname/chdir'
require 'facets/string/modulize'

module ConceptQL
  class Nodifier
    attr_reader :operators

    def initialize
      @operators = {}
      dir = Pathname.new(__FILE__).dirname()
      dir.chdir do
        Pathname.glob("nodes/*.rb").each do |file|
          require_relative file
          operator = file.basename('.*').to_s.to_sym
          klass = Object.const_get("conceptQL/nodes/#{operator}".modulize)
          @operators[operator] = klass
        end
      end
    end

    def create(scope, operator, *values)
      node = operators[operator].new(*values)
      node.scope = scope
      node
    end

    def to_metadata
      Hash[operators.map { |k, v| [k, v.to_metadata]}.select { |k, v| v[:desc] }]
    end
  end
end
