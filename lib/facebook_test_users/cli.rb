require 'thor'
require 'facebook_test_users'

module FacebookTestUsers
  class CLI < Thor
    class Apps < Thor

      check_unknown_options!
      def self.exit_on_failure?() true end

      default_task :list

      desc "add", "Tell fbtu about a new application (must already exist on FB)"
      method_option "app_id", :type => :string, :required => true, :banner => "OpenGraph ID of the app"
      method_option "app_secret", :type => :string, :required => true, :banner => "App's secret key"
      method_option "name", :type => :string, :required => true, :banner => "Name of the app (so you don't have to remember its ID)"
      def add
        FacebookTestUsers::App.create!(:name => options[:name], :id => options[:app_id], :secret => options[:app_secret])
        list
      end

      desc "list", "List the applications fbtu knows about"
      def list
        App.all.each do |app|
          puts "#{app.name} (id: #{app.id})"
        end
      end

    end # Apps

    class Users < Thor
      check_unknown_options!
      def self.exit_on_failure?() true end

      desc "list", "List available test users for an application"
      method_option "app", :aliases => %w[-a], :type => :string, :required => true, :banner => "Name of the app"

      def list
        app = find_app!(options[:app])
        if app.users.any?
          shell.print_table([
              ['User ID', 'Access Token', 'Login URL'],
              *(app.users.map do |user|
                  [user.id, user.access_token, user.login_url]
                end)
            ])
        else
          puts "App #{app.name} has no users."
        end
      end

      desc "add", "Add a test user to an application"
      method_option "app", :aliases => %w[-a], :type => :string, :required => true, :banner => "Name of the app"

      def add
        app = find_app!(options[:app])
        user = app.create_user
        puts "User ID:      #{user.id}"
        puts "Access Token: #{user.access_token}"
        puts "Login URL:    #{user.login_url}"
      end

      desc "rm", "Remove a test user from an application"
      method_option "app", :aliases => %w[-a], :type => :string, :required => true, :banner => "Name of the app"
      method_option "user", :banner => "ID of the user to remove", :aliases => %w[-u], :type => :string, :required => true

      def rm
        app = find_app!(options[:app])
        user = app.users.find do |user|
          user.id.to_s == options[:user].to_s
        end

        if user
          user.destroy
        else
          $stderr.write("Unknown user '#{options[:user]}'")
          raise ArgumentError, "No such user"
        end
      end

      private
      def find_app!(name)
        app = App.find_by_name(options[:app])
        unless app
          $stderr.puts "Unknown app #{options[:app]}."
          $stderr.puts "Run 'fbtu apps' to see known apps."
          raise ArgumentError, "No such app"
        end
        app
      end

    end # Users

    check_unknown_options!
    def self.exit_on_failure?() true end

    desc "apps", "Commands for managing FB applications"
    subcommand :apps, FacebookTestUsers::CLI::Apps

    desc "apps", "Commands for managing FB applications' test users"
    subcommand :users, FacebookTestUsers::CLI::Users
  end
end
