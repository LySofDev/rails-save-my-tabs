module Concerns
  class AuthenticateUser

    def initialize(params)
      @email = params[:data][:attributes][:email]
      @password = params[:data][:attributes][:password]
      @user = User.find_by_email(@email)
      @success = @user && @user.has_password(@password)
    end

    def json
      @success ? security_token : authentication_errors
    end

    def status
      @success ? 200 : 422
    end

    private

    def security_token
      Concerns::JSONTemplates.security_token(@user)
    end

    def authentication_errors
      Concerns::JSONTemplates.errors(["Invalid email or password."])
    end

  end
end
