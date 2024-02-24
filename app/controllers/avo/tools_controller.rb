require_relative '../../models/settings'

class Avo::ToolsController < Avo::ApplicationController
  def settings
    @page_title = "Settings"
    add_breadcrumb "Settings"
  end

  def update_settings
    @errors = ActiveModel::Errors.new(Settings.new)

    # Process each setting
    settings_params.each do |_, settings_hash|
      settings_hash.each do |key, value|
        next if value.nil?

        # Attempt to update the setting
        begin
          Settings.send("#{key}=", value.strip)
        rescue => e
          @errors.add(:base, "Failed to update setting '#{setting_key}': #{e.message}")
        end
      end
    end

    if @errors.any?
      # If there are any errors, re-render the settings page (or another appropriate view) with error messages
      render :settings, status: :unprocessable_entity
    else
      # On success, redirect to the settings page with a success notice
      redirect_to settings_path, notice: "Settings were successfully updated."
    end
  end

  private

  def settings_params
    params.require(:settings).permit(general: [:orientation], spotify: [:canvas_feature_enabled])
  end
end
