module Concerns
  class CreateTab

    def initialize(current_user, params)
      @user = current_user
      @title = params[:data][:attributes][:title]
      @url = params[:data][:attributes][:url]
      @tab = Tab.new do |t|
        t.user = @user
        t.url = @url if @url
        t.title = @title if @title
      end
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
      Concerns::JSONTemplates.errors(@tab.errors.full_messages)
    end

  end
end
