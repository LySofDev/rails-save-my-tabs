module Concerns
  class AuthenticateUser

    def initialize(params)
      @email = params[:data][:attributes][:email]
      @password = params[:data][:attributes][:password]
      @user = User.find_by_email(@email)
      @success = @user && @user.has_password(@password)
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

  end
end
