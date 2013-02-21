
module Tableling

  class View
    attr_reader :name, :config, :settings, :base_query, :base_count_query

    def initialize name, config, options = {}, &block

      @name, @config = name, config
      @fields = []

      @base_query = @config.model
      @base_count_query = nil

      @settings = Settings.new @config.settings
      extend @settings.dsl

      instance_eval &block if block
      @frozen = true
    end

    def field name, options = {}, &block
      return @fields.find{ |f| f.name.to_s == name.to_s } if @frozen
      @fields.delete_if{ |f| f.name.to_s == name.to_s }
      Field.new(name, self, options, &block).tap{ |f| @fields << f }
    end

    def quick_search &block
      @quick_search = block
    end

    def base base_query
      @base_query = base_query
    end

    def base_count base_count_query
      @base_count_query = base_count_query
    end

    def process options = {}
      
      q = options[:base] || @base_query
      cq = options[:base_count] || @base_count_query

      if @quick_search and options[:quickSearch].present?
        q = @quick_search.call q, options[:quickSearch].to_s
        cq = @quick_search.call cq, options[:quickSearch].to_s if cq
      end

      total = (cq || q).count
      raise BaseQueryError, "Count query must return a number" unless total.kind_of?(Fixnum)

      if options[:sort].present?
        options[:sort].select{ |item| item.match /\A([^ ]+)* (asc|desc)\Z/i }.each do |item|
          parts = item.split ' '
          f = field parts[0]
          q = f.with_order q, parts[1].downcase.to_sym if f
        end
      end

      @fields.each{ |f| q = f.with_includes q }

      limit = options[:pageSize].to_i
      limit = 10 if limit <= 0
      q = q.limit limit

      offset = options[:page].to_i - 1
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
