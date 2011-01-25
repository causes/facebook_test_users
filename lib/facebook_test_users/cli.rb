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
        FacebookTestUsers::App.all.each do |app|
          puts "#{app.name} (id: #{app.id})"
        end
      end

    end

    check_unknown_options!
    def self.exit_on_failure?() true end

    desc "apps", "Commands for managing FB applications"
    subcommand :apps, FacebookTestUsers::CLI::Apps
  end
end
