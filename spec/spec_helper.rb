require 'pp'
require 'stringio'
require 'tempfile'

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
        end

        @out = @out.string
        @err = @err.string
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

  end
end

RSpec.configure do |config|
  config.include FBTU::SpecHelpers::CliTestMethods
  config.extend  FBTU::SpecHelpers::SemanticNames

  config.before(:each) do
    @fbtu_dotfile = Tempfile.new('fbtu-prefs')
    FacebookTestUsers::DB.filename = @fbtu_dotfile.path
  end

  config.before(:all) { FakeWeb.allow_net_connect = false }

end
