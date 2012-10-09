
describe Book do

  it "should respond to #tableling" do
    Book.respond_to?(:tableling).should be_true
  end
end
