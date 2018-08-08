module Concerns
  class IndexTabs

    def initialize(current_user, params)
      @user = current_user
      @offset = params[:offset] || 1
      @count = params[:count] || 10
    end

    def json
      {
        data: {
          count: @user.tabs.count,
          page: {
            count: @count,
            offset: @offset
          },
          tabs: @user.tabs.order(created_at: 'DESC').page(@offset).per(@count).collect { |tab|
            {
              type: "tabs",
              attributes: {
                id: tab.id,
                title: tab.title,
                url: tab.url,
                userId: tab.user.id
              }
            }
          }
        }
      }
    end

    def status
      200
    end

  end
end
