module Tableling
end

[ :engine, :model, :field, :version, :activerecord ].each do |lib|
  require File.expand_path("../tableling-rails/#{lib}", __FILE__)
end
