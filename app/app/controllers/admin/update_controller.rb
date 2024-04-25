module Admin
  class UpdateController < ApplicationController
    # GET /admin/update
    def update
      begin
        UpframeUpdateService.update
        flash[:notice] = 'Upframe update started successfully.'
        redirect_to admin_developer_path
      rescue StandardError => e
        flash[:alert] = "Failed to update Upframe: #{e.message}"
        redirect_to admin_developer_path
      end
    end
  end
end