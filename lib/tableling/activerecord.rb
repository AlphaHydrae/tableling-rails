Dir[File.join File.dirname(__FILE__), File.basename(__FILE__, '.*'), '*.rb'].each{ |lib| require lib }
ActiveRecord::Base.send :include, Tableling::ActiveRecord::Extensions
