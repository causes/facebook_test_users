require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper'))

describe "fbtu users list" do
  before(:each) do
    fbtu %w[apps add --name alpha --app-id 123456 --app-secret abcdef]
    FakeWeb.register_uri(:get,
      'https://graph.facebook.com/oauth/access_token?client_id=123456&client_secret=abcdef&grant_type=client_credentials',
      :body => 'access_token=doublesecret')

    user_data = {
      "data" => [{
          "id" => 74040,
          "access_token" => 4992011197,
          "login_url" => "https://facebook.example.com/login/74040",
        }, {
          "id" => 78767,
          "access_token" => 9178342034,
          "login_url" => "https://facebook.example.com/login/78767",
        }]
    }

    FakeWeb.register_uri(:get,
      'https://graph.facebook.com/123456/accounts/test-users?access_token=doublesecret',
      :body => user_data.to_json)

  end

  it "lists available users" do
    fbtu %w[users list --app alpha]
    @out.should include("74040")
    @out.should include("https://facebook.example.com/login/74040")

    @out.should include("78767")
  end

  it "does something reasonable when the app doesn't exist" do
    lambda do
      fbtu %w[users list --app omega], :quiet => true
    end.should raise_error
    @err.should include("Unknown app")
  end
end
