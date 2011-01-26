require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper'))

describe "fbtu users nuke" do
  before(:each) do
    fbtu %w[apps add --name alpha --app-id 123456 --app-secret abcdef]
    FakeWeb.register_uri(:get,
      'https://graph.facebook.com/oauth/access_token?client_id=123456&client_secret=abcdef&grant_type=client_credentials',
      :body => 'access_token=doublesecret')

    user1 = {
      "id" => 21055,
      "access_token" => 9494864868,
      "login_url" => "https://facebook.example.com/log_this_guy_in?who=thatguy",
    }
    user2 = {
      "id" => 11442,
      "access_token" => 5688139914,
      "login_url" => "https://facebook.example.com/log_this_guy_in?who=thatguy",
    }

    FakeWeb.register_uri(:get,
      'https://graph.facebook.com/123456/accounts/test-users?access_token=doublesecret',
      :body => {:data => [user1, user2]}.to_json)
  end

  it "deletes all the users" do
    FakeWeb.register_uri(:delete,
      "https://graph.facebook.com/21055?access_token=9494864868",
      :body => "true")
    FakeWeb.register_uri(:delete,
      "https://graph.facebook.com/11442?access_token=5688139914",
      :body => "true")

    fbtu %w[users nuke --app alpha]

    FakeWeb.should have_requested(:delete,
      "https://graph.facebook.com/21055?access_token=9494864868")
    FakeWeb.should have_requested(:delete,
      "https://graph.facebook.com/11442?access_token=5688139914")
  end
end
