
module Tableling

  module Model
    extend ActiveSupport::Concern

    module ClassMethods

      def tableling options = {}, &block
        @tableling ||= Tableling::Configuration.new(self, options, &block)
      end
    end
  end
end
