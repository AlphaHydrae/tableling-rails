
module Tableling

  module ActiveRecordModel

    def initialize_model options = {}
      @model = options[:model]
      @field_options[:model] = @model
    end

    def base_query
      @model
    end
  end

  module ActiveRecordExt
    extend ActiveSupport::Concern

    module ClassMethods
      def tableling options = {}, &block
        @model ||= Model.new(:modules => ActiveRecordModel, :model => self, &block)
      end
    end
  end
end

ActiveRecord::Base.send :include, Tableling::ActiveRecordExt
