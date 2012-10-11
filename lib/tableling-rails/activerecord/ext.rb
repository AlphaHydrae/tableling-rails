module Tableling

  module ActiveRecord

    module Extensions
      extend ActiveSupport::Concern

      module ClassMethods
        def tableling options = {}, &block
          @model ||= Tableling::Model.new(:modules => Tableling::ActiveRecord::Model, :model => self, &block)
        end
      end
    end
  end
end
