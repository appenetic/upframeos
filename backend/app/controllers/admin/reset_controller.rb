module Admin
  class ResetController < ApplicationController
    def reset
      ResetService.reset
      redirect_to admin_developer_path
    end
  end
end