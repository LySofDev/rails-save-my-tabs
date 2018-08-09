module Concerns
  class ShowTab

    def initialize(current_user, params)
      @user = current_user
      @tab = Tab.find_by_id(params[:id])
      @success = @tab && @tab.user.id == @user.id
    end

    def json
      @success ? tab_entity : tab_not_found
    end

    def status
      @success ? 200 : 404
    end

    private

    def tab_entity
      Concerns::JSONTemplates.tab_entity(@tab)
    end

    def tab_not_found
      Concerns::JSONTemplates.errors(["Tab not found"])
    end

  end
end
