
module Tableling

  class TypeSerializer

    def initialize type, block
      @type, @block = type, block
    end

    def match? value
      value.kind_of? @type
    end

    def serialize value
      @block.call value
    end
  end
end
