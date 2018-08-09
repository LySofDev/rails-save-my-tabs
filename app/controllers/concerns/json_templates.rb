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

    def self.tab_entity(tab)
      {
        data: {
          type: "tabs",
          attributes: {
            id: tab.id,
            url: tab.url,
            title: tab.title,
            userId: tab.user.id
          }
        }
      }
    end

    def self.tab_collection(tabs, offset, count)
      {
        data: {
          count: tabs.count,
          page: {
            offset: offset,
            count: count
          },
          tabs: tabs.collect { |tab|
            {
              type: "tabs",
              attributes: {
                id: tab.id,
                url: tab.url,
                title: tab.title,
                userId: tab.user.id
              }
            }
          }
        }
      }
    end

  end
end
