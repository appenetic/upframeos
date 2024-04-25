module Admin
  class UpdateController < ApplicationController
    # GET /admin/update
    def update
      begin
        UpframeUpdateService.update
        flash[:notice] = 'Deployment process started successfully.'
        redirect_to admin_developer_path
      rescue StandardError => e
        flash[:alert] = "Failed to start deployment: #{e.message}"
        redirect_to admin_developer_path
      end
    end
  end
end