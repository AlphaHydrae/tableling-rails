
module Tableling

  class Model

    def initialize options = {}, &block

      @field_options = {}

      @modules = options[:modules] || []
      @modules = [ @modules ] unless @modules.kind_of?(Array)
      @modules.each{ |mod| extend mod }
      initialize_model options

      @fields = []
      @field_modules = options[:field_modules] || []
      @field_modules = [ @field_modules ] unless @field_modules.kind_of?(Array)

      instance_eval &block if block
    end

    def field name, options = {}, &block
      if field = @fields.find{ |f| f.name.to_s == name.to_s }
        return field
      end
      # TODO: do not add field if it's already there
      Field.new(name, @field_options.merge({ :modules => @field_modules }).merge(options), &block).tap{ |f| @fields << f }
    end

    def quick_search &block
      @quick_search = block
    end

    def process params
      
      q = base_query

      if @quick_search and params[:quick_search].present?
        q = @quick_search.call q, params[:quick_search].to_s
      end

      total = q.count :all

      if params[:sort].present?
        params[:sort].select{ |item| item.match /\A([^ ]+)* (asc|desc)\Z/ }.each do |item|
          parts = item.split ' '
          q = field(parts[0]).with_order q, parts[1].to_sym
        end
      end

      limit = params[:page_size].to_i
      limit = 10 if limit <= 0
      q = q.limit limit

      offset = params[:page].to_i - 1
      offset = 0 if offset < 0
      q = q.offset offset * limit

      {
        :total => total,
        :data => q.all.collect{ |o|
          @fields.inject({}){ |memo,f| memo[f.name] = f.extract(o); memo }
        }
      }
    end
  end
end
