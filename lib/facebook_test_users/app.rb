require 'json'

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

      if all.find {|app| app.name == new_guy.name }
        raise ArgumentError, "App names must be unique, and there is already an app named \"#{new_guy.name}\"."
      end

      DB.update do |data|
        data[:apps] ||= []
        data[:apps] << new_guy.attrs
      end
    end

    def users
      users_data = RestClient.get(users_url, :params => {
          :access_token => access_token
        })

      JSON[users_data]["data"].map do |user_data|
        User.new(user_data)
      end
    end

    def create_user
      user_data = RestClient.post(users_url,
        :access_token => access_token,
        :installed => true)

      User.new(JSON[user_data])
    end

    ## query methods
    def self.all
      if DB[:apps]
        DB[:apps].map {|attrs| new(attrs) }
      else
        []
      end
    end

    def self.find_by_name(name)
      all.find {|a| a.name == name}
    end

    private

    def users_url
      GRAPH_API_BASE + "/#{id}/accounts/test-users"
    end

    def access_token
      @access_token ||= AccessToken.get(id, secret)
    end

    def validate!
      unless name && name =~ /\S/
        raise ArgumentError, "App name must not be empty"
      end

      unless id && id =~ /^[0-9a-f]+$/i
        raise ArgumentError, "App id must be a nonempty hex string"
      end

      unless secret && secret =~ /^[0-9a-f]+$/i
        raise ArgumentError, "App secret must be a nonempty hex string"
      end
    end

  end
end
