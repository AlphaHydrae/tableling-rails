
module Tableling

  class Settings

    def initialize parent = nil
      @parent = parent
      @serializers = []
    end

    def configure &block
      instance_eval &block if block
    end

    def serialize type, &block
      @serializers << Serializer.new(type, block)
    end

    def serializers
      (@parent ? @parent.serializers : []) + @serializers.dup
    end

    def dsl
      m = Module.new do

        def serialize type, &block
          @settings.serialize type, &block
        end
      end
      m.instance_variable_set :@settings, self
      m
    end
  end
end
