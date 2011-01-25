require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe "fbtu apps" do
  it "raises an error on baloney" do
    lambda do
      fbtu %w[apps somecrap]
    end.should raise_error
  end
end
