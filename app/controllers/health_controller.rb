class HealthController < ApplicationController
  def status
    render json: { success: true }
  end
end
