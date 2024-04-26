ActiveAdmin.register_page "Settings" do
  menu priority: 3, label: "Settings"

  content title: 'Settings' do
    settings = controller.load_settings
    render partial: 'layouts/admin/settings_form', locals: { settings_form: settings }
  end

  page_action :update_settings, method: :post do
    original_settings = load_settings
    Settings.orientation = permitted_params[:orientation]
    Settings.wifi_country = permitted_params[:wifi_country]
    Settings.wifi_ssid = permitted_params[:wifi_ssid]
    Settings.wifi_password = permitted_params[:wifi_password]
    Settings.canvas_feature_enabled = ActiveRecord::Type::Boolean.new.cast(permitted_params[:canvas_feature_enabled].to_i)
    updated_settings = load_settings

    if wifi_configuration_changed?(original_settings, updated_settings)
      update_wifi_config
    end

    if orientation_changed?(original_settings, updated_settings)
      update_orientation
    end

    if browser_restart_required?(original_settings, updated_settings)
      restart_chromium
    end

    redirect_to admin_settings_path, notice: "Settings were successfully updated."
  end

  controller do
    def permitted_params
      params.require('[settings]').permit(
        :orientation,
        :wifi_country,
        :wifi_ssid,
        :wifi_password,
        :canvas_feature_enabled
      )
    end

    def load_settings
      OpenStruct.new(
        orientation: Settings.find_by(var: :orientation).value,
        wifi_country: Settings.find_by(var: :wifi_country).value,
        wifi_ssid: Settings.find_by(var: :wifi_ssid).value,
        wifi_password: Settings.find_by(var: :wifi_password).value,
        canvas_feature_enabled: Settings.find_by(var: :canvas_feature_enabled).value
      )
    end

    def wifi_configuration_changed?(original_settings, new_settings)
      return original_settings.wifi_country != new_settings.wifi_country ||
        original_settings.wifi_ssid != new_settings.wifi_ssid ||
        original_settings.wifi_password != new_settings.wifi_password
    end

    def orientation_changed?(original_settings, new_settings)
      return original_settings.orientation != new_settings.orientation
    end

    def browser_restart_required?(original_settings, new_settings)
      return original_settings.canvas_feature_enabled != new_settings.canvas_feature_enabled
    end

    def update_orientation
      unix_orientation = Settings.unix_orientation
      script_path = Rails.root.join('..', 'scripts', 'update_orientation.sh')
      success = system("#{script_path} #{unix_orientation}")
      flash[:error] = "Failed to update screen orientation" unless success
    end

    def update_wifi_config
      wifi_config = Settings.wpa_supplicant_content
      script_path = Rails.root.join('..', 'scripts', 'update_wifi_config.sh')
      success = system("sudo #{script_path} '#{wifi_config}'")
      flash[:error] = "Failed to update WiFi configuration." unless success
    end

    def restart_chromium
      ChromiumConfigurationService.restart_chromium
    end
  end
end
