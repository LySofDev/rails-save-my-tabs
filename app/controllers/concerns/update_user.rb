module Concerns
  class UpdateUser

    def initialize(current_user, params)
      @user = current_user
      update_user_with sanitized params
    end

    def status
      @success ? 200 : 422
    end

    def json
      @success ? {} : validation_errors
    end

    private

    # Update the permited user attributes from the params
    def update_user_with params
      @user.email = params[:email] if params[:email]
      @success = @user.save
    end

    def validation_errors
      Concerns::JSONTemplates.errors(@user.errors.full_messages)
    end

    def sanitized params
      params[:data][:attributes]
    end

  end
end
