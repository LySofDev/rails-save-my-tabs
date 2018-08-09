module Concerns
  class UpdateTab

    def initialize(current_user, params)
      @user = current_user
      @tab = Tab.find_by_id(params[:id])
      @updated_url = params[:data][:attributes][:url]
      @updated_title = params[:data][:attributes][:title]
      @tab.url = @updated_url if @updated_url
      @tab.title = @updated_title if @updated_title
      @success = @tab.save
    end

    def json
      @success ? tab_entity : validation_errors
    end

    def status
      @success ? 200 : 422
    end

    private

    def tab_entity
      Concerns::JSONTemplates.tab_entity(@tab)
    end

    def validation_errors
      if @tab
        Concerns::JSONTemplates.errors(@tab.errors.full_messages)
      else
        Concerns::JSONTemplates.errors(["Tab not found."])
      end
    end

  end
end
