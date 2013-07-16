
module Tableling

  class Settings

    def initialize parent = nil
      @parent = parent
      @type_serializers = []
    end

    def configure &block
      instance_eval &block if block
    end

    def serialize_type type, &block
      @type_serializers << TypeSerializer.new(type, block)
    end

    def type_serializers
      (@parent ? @parent.type_serializers : []) + @type_serializers
    end

    def dsl
      m = Module.new do

        def serialize_type type, &block
          @settings.serialize_type type, &block
        end
      end
      m.instance_variable_set :@settings, self
      m
    end
  end
end
