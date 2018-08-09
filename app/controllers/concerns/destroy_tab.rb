module Concerns
  class DestroyTab

    def initialize(current_user, params)
      @user = current_user
      @tab = Tab.find_by_id(params[:id])
      @success = @tab && @tab.user.id == @user.id && @tab.destroy
    end

    def json
      {}
    end

    def status
      @success ? 200 : 422
    end

  end
end
