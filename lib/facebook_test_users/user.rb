require 'uri'

module FacebookTestUsers
  class User

    attr_reader :id, :access_token, :login_url

    def initialize(attrs)
      # Hacky, but it allows for use of symbol keys, which are nice in
      # a console.
      @id, @access_token, @login_url = %w[id access_token login_url].map do |field|
        attrs[field.to_s] || attrs[field.to_sym]
      end
    end

    def destroy
      RestClient.delete(destroy_url)
    end

    private

    def destroy_url
      GRAPH_API_BASE + "/#{id}?access_token=#{URI.escape(access_token.to_s)}"
    end
  end
end
