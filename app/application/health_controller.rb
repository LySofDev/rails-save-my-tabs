class HealthController < ApplicationController

  def status
    head 200
  end

  def reset
    Tab.destroy_all
    User.destroy_all
    head 200
  end

end
