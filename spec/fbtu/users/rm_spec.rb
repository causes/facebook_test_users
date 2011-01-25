require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper'))

describe "fbtu users rm" do
  before(:each) do
    fbtu %w[apps add --name alpha --app-id 123456 --app-secret abcdef]
    FakeWeb.register_uri(:get,
      'https://graph.facebook.com/oauth/access_token?client_id=123456&client_secret=abcdef&grant_type=client_credentials',
      :body => 'access_token=doublesecret')

    user = {
      "id" => 21055,
      "access_token" => 9494864868,
      "login_url" => "https://facebook.example.com/log_this_guy_in?who=thatguy",
    }

    FakeWeb.register_uri(:get,
      'https://graph.facebook.com/123456/accounts/test-users?access_token=doublesecret',
      :body => {:data => [user]}.to_json)
  end

  it "deletes the user" do
    FakeWeb.register_uri(:delete,
      "https://graph.facebook.com/21055?access_token=9494864868",
      :body => "true")

    fbtu %w[users rm --app alpha  --user 21055]

    FakeWeb.should have_requested(:delete,
      "https://graph.facebook.com/21055?access_token=9494864868")
  end

  it "tells you if there was no such user" do
    lambda do
      fbtu %w[users rm --app alpha  --user bogus], :quiet => true
    end.should raise_error
    @err.should include("Unknown user")
  end
end
