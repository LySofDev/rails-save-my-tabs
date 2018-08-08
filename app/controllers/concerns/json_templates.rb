module Concerns
  module JSONTemplates

    def self.security_token(user)
      {
        data: {
          type: "security_tokens",
          attributes: {
            prefix: "Bearer",
            token: user.as_token
          }
        }
      }
    end

    def self.errors(messages)
      { errors: messages }
    end

    def self.resource(type, attributes)
      {
        data: {
          type: type,
          attributes: attributes
        }
      }
    end

  end
end
