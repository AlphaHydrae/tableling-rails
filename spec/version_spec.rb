require 'spec_helper'

describe "Version" do
  it "should be correct" do
    version_file = File.expand_path '../../VERSION', __FILE__
    Tableling::VERSION.should == File.open(version_file, 'r').read
  end
end
