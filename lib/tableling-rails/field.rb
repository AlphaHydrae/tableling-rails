
module Tableling

  class Field
    attr_reader :name

    def initialize name, view, options = {}, &block

      @name, @view = name.to_s, view
      @value_column = options[:value].try :to_s
      @includes = options[:includes]

      if options[:order] == false
        @no_order = true
      elsif options[:order]
        @order_column = options[:order].to_s
      end

      instance_eval &block if block
    end

    def order &block
      @order_block = block
    end

    def no_order
      @no_order = true
    end

    def value &block
      @value_block = block
    end

    def includes &block
      @includes_block = block
    end

    def with_order query, direction
      return if @no_order
      if @order_block
        @order_block.call query, direction
      else
        query.order "#{model.table_name}.#{@order_column || @name} #{direction}"
      end
    end

    def with_includes query
      if @includes_block
        @includes_block.call query
      elsif @includes
        query.includes @includes
      else
        query
      end
    end

    def extract object
      if @value_block
        @value_block.call object
      else
        serialize object.send(@value_column || @name)
      end
    end

    private

    def model
      @view.config.model
    end

    def serialize value
      type_serializer = @view.settings.type_serializers.find{ |s| s.match? value }
      type_serializer ? type_serializer.serialize(value) : value
    end
  end
end
