require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper'))

describe "fbtu apps add" do
  it "lets you add an app" do
    fbtu %w[apps add --app-id 123456 --app-secret 7890 --name hydrogen]

    fbtu %w[apps list]
    @out.should include("hydrogen")
    @out.should_not include("squirrel")
  end

  it "won't let you add an app with a bogus ID" do
    lambda do
      fbtu %w[apps add --app-id xyzzy --app-secret 7890 --name hydrogen]
    end.should raise_error
  end

  it "won't let you add an app with a bogus secret" do
    lambda do
      fbtu %w[apps add --app-id 123456 --app-secret xyzzy --name hydrogen]
    end.should raise_error
  end

  it "won't let you add an app without a name"
  it "won't let you add an app with a duplicate name"
end
