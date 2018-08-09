module Concerns
  class IndexTabs

    def initialize(current_user, params)
      @user = current_user
      @offset = params[:offset] || 1
      @count = params[:count] || 10
    end

    def json
      Concerns::JSONTemplates.tab_collection({
        tabs: @user.tabs.order(created_at: 'DESC').page(@offset).per(@count),
        offset: @offset,
        count: @count,
        total_count: @user.tabs.count
      })
    end

    def status
      200
    end

  end
end
