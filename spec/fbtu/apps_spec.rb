require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe "fbtu apps" do
  it "raises an error on baloney" do
    lambda do
      fbtu %w[apps somecrap]
    end.should raise_error
  end

  it "defaults to listing apps" do
    fbtu %w[apps add --name shlomo --app-id 12345 --app-secret abcdef]
    fbtu %w[apps]
    @out.should include("shlomo")
    @out.should include("12345")
  end

end
