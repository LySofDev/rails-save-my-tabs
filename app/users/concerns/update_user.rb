module Concerns
  class UpdateUser

    def initialize(current_user, params)
      @user = current_user
      @updated_email = params[:data][:attributes][:email]
      @user.email = @updated_email if @updated_email
      @success = @user.save
    end

    def status
      @success ? 200 : 422
    end

    def json
      @success ? {} : validation_errors
    end

    private

    def validation_errors
      Concerns::JSONTemplates.errors(@user.errors.full_messages)
    end

  end
end
