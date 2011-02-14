require 'pp'
require 'stringio'
require 'tempfile'
require 'digest/md5'

require 'facebook_test_users'
require 'facebook_test_users/cli'

require 'fakeweb'
require 'fakeweb_matcher'

module FBTU
  module SpecHelpers
    module SemanticNames

      def given(name)
        it_should_behave_like(name)
      end

    end

    module CliTestMethods
      def fbtu(argv_ish, options={})
        @out = StringIO.new
        @err = StringIO.new

        begin
          capture_stdout_into(@out) do
            capture_stderr_into(@err) do
              FacebookTestUsers::CLI.start(argv_ish)
            end
          end
        rescue Exception => e
          unless options[:quiet]
            puts "Something failed.\nArgs:%s\nstdout:\n%s\n\nstderr:\n%s\n" % [
              argv_ish.inspect,
              @out.string,
              @err.string
            ]
          end
          raise e      # always propagate failure up the stack
        ensure
          @out = @out.string
          @err = @err.string
        end
      end

      def capture_stdout_into(io)
        $stdout = io
        yield
      ensure
        $stdout = STDOUT
      end

      def capture_stderr_into(io)
        $stderr = io
        yield
      ensure
        $stderr = STDERR
      end

    end # CliTestMethods

    module SetupHelpers

      def self.reset!
        UserList.reset!
      end

      class UserList

        def self.reset!
          @users = Hash.new {|h,k| h[k] = []}
        end

        def self.users
          @users || reset!
        end

        def self.add(app, user)
          users[app] << user
        end

        def self.for(app)
          users[app]
        end

      end # UserList

      def add_app(name, opts={})
        appinfo = {
          :name => name,
          :app_id => opts[:app_id] || 123456,
          :app_secret => opts[:app_secret] || 'abcdef'
        }

        appinfo[:access_token] = Digest::MD5.hexdigest(appinfo[:app_id].to_s + "::" + appinfo[:app_secret].to_s)

        FakeWeb.register_uri(:get,
          "https://graph.facebook.com/oauth/access_token?client_id=#{appinfo[:app_id]}&client_secret=#{appinfo[:app_secret]}&grant_type=client_credentials",
          :body => "access_token=#{appinfo[:access_token]}")

        fbtu (%w[apps add --name] << name <<
          '--app-id' << appinfo[:app_id] <<
          '--app-secret' << appinfo[:app_secret])

        app = FacebookTestUsers::App.find_by_name(name)
        fakeweb_register_users_url(app, [])
        app
      end

      def add_user_to(app)
        # real FB test users all have IDs starting with 10000 (or at
        # least the ones that I've seen; N=20 or so)
        user_id = "10000" + rand(9999999999).to_s
        user_access_token = Digest::MD5.hexdigest(user_id)

        user_data = {
          "id" => user_id,
          "access_token" => user_access_token,
          "login_url" => "https://facebook.example.com/login/#{user_id}",
        }

        FakeWeb.register_uri(:post,
          "https://graph.facebook.com/#{app.id}/accounts/test-users",
          :body => user_data.to_json)


        # XXX ideally we'd call fbtu, but then we're stuck parsing its
        # textual output to get the fields to create a user object
        user = app.create_user
        UserList.add(app, user)
        fakeweb_register_users_url(app, UserList.for(app))
        user
      end

      protected

      # If this looks like it's getting called a bunch, it's because
      # the set of users changes all the time, and so their JSONified
      # form has to be refreshed.
      def fakeweb_register_users_url(app, users)
        user_data = users.map do |u|
          {
            "id" => u.id,
            "access_token" => u.access_token,
            "login_url" => u.login_url
          }
        end

        FakeWeb.register_uri(:get,
          "https://graph.facebook.com/#{app.id}/accounts/test-users?access_token=#{app.access_token}",
          :body => {"data" => user_data}.to_json)
      end

    end # SetupHelpers

  end
end

RSpec.configure do |config|
  config.include FBTU::SpecHelpers::CliTestMethods
  config.include FBTU::SpecHelpers::SetupHelpers
  config.extend  FBTU::SpecHelpers::SemanticNames

  config.before(:each) { FBTU::SpecHelpers::SetupHelpers.reset! }

  config.before(:each) do
    @fbtu_dotfile = Tempfile.new('fbtu-prefs')
    FacebookTestUsers::DB.filename = @fbtu_dotfile.path
  end

  config.before(:all) { FakeWeb.allow_net_connect = false }

end
