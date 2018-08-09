module Concerns
  module JSONTemplates

    def self.errors(messages)
      { errors: messages }
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

    def self.tab_collection(tabs: [], total_count: 0, offset: 1, count: 10)
      {
        data: {
          count: total_count,
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
    
  end
end
