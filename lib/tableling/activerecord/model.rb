module Tableling

  module ActiveRecord

    module Model

      def initialize_model options = {}
        @model = options[:model]
        @field_options[:model] = @model
        @field_options[:modules] = Tableling::ActiveRecord::Field
      end

      def base_query
        @model
      end
    end
  end
end
