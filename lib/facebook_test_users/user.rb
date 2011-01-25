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

  end
end

    
