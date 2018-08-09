module Concerns
  class CreateTab

    def initialize(current_user, params)
      @user = current_user
      create_tab_with santized params
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

    def santized params
      params[:data][:attributes]
    end

    def create_tab_with params
      @tab = Tab.new do |t|
        t.title = params[:title] if params[:title]
        t.url = params[:url] if params[:url]
        t.user = @user
      end
      @success = @tab.save
    end

    def validation_errors
      Concerns::JSONTemplates.errors(@tab.errors.full_messages)
    end

  end
end
