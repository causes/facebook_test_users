require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper'))

describe "fbtu users friend" do
  before(:each) do
    alpha = add_app('alpha')

    @alice = add_user_to(alpha)
    @bob = add_user_to(alpha)

    FakeWeb.register_uri(:post,
      "https://graph.facebook.com/#{@alice.id}/friends/#{@bob.id}",
      :body => "true")
    FakeWeb.register_uri(:post,
      "https://graph.facebook.com/#{@bob.id}/friends/#{@alice.id}",
      :body => "true")
  end

  it "adds a user with the app installed" do
    fbtu ['users', 'friend',
      '--app', 'alpha',
      '--user1', @alice.id,
      '--user2', @bob.id]

    FakeWeb.should have_requested(:post,
      "https://graph.facebook.com/#{@alice.id}/friends/#{@bob.id}")
    FakeWeb.should have_requested(:post,
      "https://graph.facebook.com/#{@bob.id}/friends/#{@alice.id}")
  end
end
