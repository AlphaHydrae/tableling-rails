
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
          # TODO: handle unknown fields
          f = @fields.find{ |f| f.working_name.to_s == parts[0] }
          q = f.with_order q, parts[1].downcase.to_sym if f
        end
      end

      @fields.each{ |f| q = f.with_includes q }

      response_options = {
        total: total
      }

      page_size = options[:pageSize].to_i
      page_size = 10 if page_size <= 0
      q = q.limit page_size

      max_page = (total.to_f / page_size).ceil
      page = options[:page].to_i

      # TODO: allow this to be disabled
      if page < 1 or page > max_page
        page = 1
        response_options[:page] = 1
      end

      q = q.offset (page - 1) * page_size

      serialize_response q, response_options
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

    def serialize_response query, response_options = {}

      res = response_options.merge data: query.all

      if @serialize_response_block
        @serialize_response_block.call res
      else
        res[:data] = res[:data].collect{ |r| serialize_record r }
        res
      end
    end

    def serialize_record record
      @serialize_record_block ? @serialize_record_block.call(record) : @fields.inject({}){ |memo,f| memo[f.working_name] = f.extract(record); memo }
    end
  end
end
