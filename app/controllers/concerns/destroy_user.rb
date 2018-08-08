module Concerns
  class DestroyUser

    def initialize(current_user)
      current_user.destroy
    end

    def status
      200
    end

    def json
      {}
    end

  end
end
