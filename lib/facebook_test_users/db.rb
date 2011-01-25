require 'yaml'

module FacebookTestUsers

  # This is about the dumbest DB you can get. It's a hash that knows
  # how to serialize itself. Dumb, but it gets the job done.
  class DB
    class << self

      def [](arg)
        # FIXME deep-freeze this; shallow freezing is insufficient
        result = yaml[arg]
        result.freeze
        result
      end

      def update
        @cached_yaml = nil
        data = _yaml
        yield data

        # do this *before* blowing away the db
        data_as_yaml = data.to_yaml
        File.open(filename, 'w') { |f| f.write(data_as_yaml) }
      end

      def filename
        @filename || File.join(ENV['HOME'], '.fbturc')
      end

      def filename=(f)
        @cached_yaml = nil
        @filename = f
      end

      private

      def yaml
        @cached_yaml ||= _yaml
      end

      def _yaml
        YAML.load_file(filename) || {}
      end

    end
  end
end
