
module Tableling

  class Field
    attr_reader :name
    # TODO: extract active record functionality

    def initialize name, options = {}, &block
      @name = name.to_s
      @order_column = options[:order].try :to_s
      @value_column = options[:value].try :to_s
      @includes = options[:includes]
      @model = options[:model]
      Array.wrap(options[:modules] || []).each do |mod|
        extend mod
      end
      instance_eval &block if block
    end

    def order &block
      @order_block = block
    end

    def value &block
      @value_block = block
    end

    def includes &block
      @includes_block = block
    end

    def with_order query, direction
      if @order_block
        @order_block.call query, direction
      else
        query.order "#{@model.table_name}.#{@order_column || @name} #{direction}"
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
        object.send(@value_column || @name).to_s
      end
    end
  end
end
