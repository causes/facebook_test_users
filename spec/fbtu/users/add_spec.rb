require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper'))

describe "fbtu users add" do
  before(:each) do
    fbtu %w[apps add --name alpha --app-id 123456 --app-secret abcdef]
    FakeWeb.register_uri(:get,
      'https://graph.facebook.com/oauth/access_token?client_id=123456&client_secret=abcdef&grant_type=client_credentials',
      :body => 'access_token=doublesecret')

    new_user = {
      "id" => 60189,
      "access_token" => 5795927166794,
      "login_url" => "https://facebook.example.com/login/60189",
    }

    FakeWeb.register_uri(:post,
      'https://graph.facebook.com/123456/accounts/test-users',
      :body => new_user.to_json)
  end

  it "adds a user with the app installed" do
    fbtu %w[users add --app alpha]
    @out.should include("60189")
  end
end
