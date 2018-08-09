module Concerns
  class CreateUser

    def initialize(params)
      @email = params[:data][:attributes][:email]
      @password = params[:data][:attributes][:password]
      @confirmation = params[:data][:attributes][:confirmation]
      @user = User.new do |u|
        u.email = @email
        u.password = @password
        u.password_confirmation = @confirmation
      end
      @success = @user.save
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

  end
end
