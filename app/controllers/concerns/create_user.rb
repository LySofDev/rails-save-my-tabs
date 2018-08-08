module Concerns
  class CreateUser

    def initialize(params)
      create_user_with sanitized params
    end

    # The JSON object representing the response
    def json
      @success ? security_token : validation_errors
    end

    # The HTTP status code representing the outcome
    def status
      @success ? 200 : 422
    end

    private

    # The JWT Security Token representing the new user
    def security_token
      Concerns::JSONTemplates.security_token(@user)
    end

    # A list of errors that were raised while validating the
    # user's registration data
    def validation_errors
      Concerns::JSONTemplates.errors(@user.errors.full_messages)
    end

    # Sanitze registration data for user initialization
    def sanitized params
      params[:data][:attributes]
    end

    # Create new user with request data
    # Store the operation's outcome in @success
    def create_user_with params
      @user = User.new do |u|
        u.email = params[:email]
        u.password = params[:password]
        u.password_confirmation = params[:confirmation]
      end
      @success = @user.save
    end

  end
end
