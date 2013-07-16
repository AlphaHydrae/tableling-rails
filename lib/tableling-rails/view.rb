
module Tableling

  class View
    attr_reader :name, :config, :settings, :fields
    attr_accessor :base_query, :base_count_query, :quick_search_block, :serialize_record_block, :serialize_response_block

    def initialize name, config, options = {}, &block

      @name, @config = name, config
      @fields = []

      @base_query = @config.model
      @base_count_query = nil

      @settings = Settings.new @config.settings

      if block
        dsl = DSL.new self
        dsl.extend @settings.dsl
        dsl.instance_eval &block
      end
    end

    def field name
      @fields.find{ |f| f.name.to_s == name.to_s }
    end

    def process options = {}
      
      q = options[:base] || @base_query
      cq = options[:base_count] || @base_count_query

      if @quick_search_block and options[:quickSearch].present?
        q = @quick_search_block.call q, options[:quickSearch].to_s
        cq = @quick_search_block.call cq, options[:quickSearch].to_s if cq
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

      serialize_response total, q
    end

    class DSL

      def initialize view
        @view = view
      end

      def field name, options = {}, &block
        @view.fields.delete_if{ |f| f.name.to_s == name.to_s }
        Field.new(name, @view, options, &block).tap{ |f| @view.fields << f }
      end

      %w(base base_count).each do |m|
        define_method m do |q|
          @view.send "#{m}_query=", q
        end
      end

      %w(quick_search serialize_record serialize_response).each do |m|
        define_method m do |&block|
          @view.send "#{m}_block=", block
        end
      end
    end

    private

    def serialize_response total, query

      res = {
        total: total,
        data: query.all
      }

      if @serialize_response_block
        @serialize_response_block.call res
      else
        res[:data] = res[:data].collect{ |r| serialize_record r }
        res
      end
    end

    def serialize_record record
      @serialize_record_block ? @serialize_record_block.call(record) : @fields.inject({}){ |memo,f| memo[f.name] = f.extract(record); memo }
    end
  end
end
