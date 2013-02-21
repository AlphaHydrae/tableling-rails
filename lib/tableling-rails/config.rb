
module Tableling

  class Configuration
    attr_reader :model, :settings

    def initialize model, options = {}, &block

      @model = model
      @views = []

      @settings = Settings.new Tableling.settings
      extend @settings.dsl

      instance_eval &block if block
      @frozen = true
    end

    def view name, options = {}, &block
      return @views.find{ |v| v.name.to_s == name.to_s } if @frozen
      @views.delete_if{ |v| v.name.to_s == name }
      View.new(name, self, options, &block).tap{ |v| @views << v }
    end

    def default_view options = {}, &block
      view :default, options, &block
    end

    def process params
      raise ConfigurationError, "You must specify a default view" unless view(:default)
      view(:default).process params
    end
  end
end
