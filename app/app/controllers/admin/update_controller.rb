module Admin
  class UpdateController < ApplicationController
    def update
      begin
        if UpframeUpdateService.update
          flash[:notice] = 'Upframe update started successfully.'
        else
          flash[:notice] = 'Upframe is already up to date; no restart needed.'
        end
        redirect_to admin_developer_path
      rescue StandardError => e
        flash[:alert] = "Failed to update Upframe: #{e.message}"
        redirect_to admin_developer_path
      end
    end
  end
end
