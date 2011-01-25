require 'pp'
require 'stringio'
require 'tempfile'

require 'facebook_test_users'
require 'facebook_test_users/cli'

module FBTU
  module SpecHelpers
    module SemanticNames

      def given(name)
        it_should_behave_like(name)
      end

    end

    module CliTestMethods
      def fbtu(argv_ish)
        @out = capture_stdout do
          @err = capture_stderr do
            FacebookTestUsers::CLI.start(argv_ish)
          end
        end
      end
      
      def capture_stdout
        $stdout = StringIO.new
        yield
        $stdout.string
      ensure
        $stdout = STDOUT
      end

      def capture_stderr
        $stderr = StringIO.new
        yield
        $stderr.string
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
end
