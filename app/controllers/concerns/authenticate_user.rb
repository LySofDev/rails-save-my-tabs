module Concerns
  class AuthenticateUser

    def initialize(params)
      authenticate_user_with sanitized params
    end

    # The JSON object representing the response
    def json
      @success ? security_token : authentication_errors
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
    def authentication_errors
      Concerns::JSONTemplates.errors(["Invalid email or password."])
    end

    # Sanitze registration data for user initialization
    def sanitized params
      params[:data][:attributes]
    end

    # Authenticate user with the provided credentials.
    # Store the outcome of the operation in @success
    def authenticate_user_with params
      @user = User.find_by_email(params[:email])
      @success = @user && @user.has_password(params[:password])
    end

  end
end
