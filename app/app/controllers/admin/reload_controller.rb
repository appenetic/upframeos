module Admin
  class ReloadController < ApplicationController
    def reload
      ReloadService.reload

      flash[:notice] = 'Reload successful.'
      redirect_to admin_developer_path
    end
  end
end
