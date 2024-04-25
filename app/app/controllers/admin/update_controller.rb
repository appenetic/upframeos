module Admin
  class UpdateController < ApplicationController
    def update
      case UpframeUpdateService.update
      when :no_updates
        flash[:notice] = 'Upframe is already up to date; no restart needed.'
      when :updates_applied
        flash[:notice] = 'Upframe update started successfully; services restarted.'
      when :failed
        flash[:alert] = 'Failed to update Upframe; check logs for details.'
      end
      redirect_to admin_developer_path
    end
  end
end
