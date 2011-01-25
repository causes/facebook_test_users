module FacebookTestUsers
  class App

    attr_reader :name, :id, :secret
    
    def initialize(attrs)
      @name, @id, @secret = attrs[:name], attrs[:id], attrs[:secret]
      validate!
    end
      
    def attrs
      {:name => name, :id => id, :secret => secret}
    end

    def self.create!(attrs)
      new_guy = new(attrs)

      DB.update do |data|
        data[:apps] ||= []
        data[:apps] << new_guy.attrs
      end
    end

    def self.all
      DB[:apps].map {|attrs| new(attrs) }
    end

    private

    def validate!
      unless name && name =~ /\S/
        raise "App name must not be empty"
      end

      unless id && id =~ /^[0-9a-f]+$/i
        raise "App id must be a nonempty hex string"
      end

      unless secret && secret =~ /^[0-9a-f]+$/i
        raise "App secret must be a nonempty hex string"
      end
    end

  end
end
