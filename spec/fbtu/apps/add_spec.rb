require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper'))

describe "fbtu apps add" do
  it "lets you add an app" do
    fbtu %w[apps add --app-id 123456 --app-secret squirrel --name hydrogen]

    fbtu %w[apps list]
    @out.should include("hydrogen")
    @out.should_not include("squirrel")
  end

  it "won't let you add an app with a bogus ID"
  it "won't let you add an app with a bogus secret"
  it "won't let you add an app without a name"
  it "won't let you add an app with a duplicate name"
end
