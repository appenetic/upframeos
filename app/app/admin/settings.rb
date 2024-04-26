ActiveAdmin.register_page "Settings" do
  menu priority: 3, label: "Settings"

  content title: 'Settings' do
    settings = OpenStruct.new(
      orientation: Settings.find_by(var: :orientation).value,
      wifi_country: Settings.find_by(var: :wifi_country).value,
      wifi_ssid: Settings.find_by(var: :wifi_ssid).value,
      wifi_password: Settings.find_by(var: :wifi_password).value,
      canvas_feature_enabled: Settings.find_by(var: :canvas_feature_enabled).value
    )
    render partial: 'layouts/admin/settings_form', locals: { settings_form: settings }
  end

  page_action :update_settings, method: :post do
    Settings.orientation = permitted_params[:orientation]
    Settings.wifi_country = permitted_params[:wifi_country]
    Settings.wifi_ssid = permitted_params[:wifi_ssid]
    Settings.wifi_password = permitted_params[:wifi_password]
    Settings.canvas_feature_enabled = ActiveRecord::Type::Boolean.new.cast(permitted_params[:canvas_feature_enabled].to_i)

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

    def update_orientation
      unix_orientation = Settings.unix_orientation
      script_path = Rails.root.join('..', 'scripts', 'update_orientation.sh')
      success = system("#{script_path} #{unix_orientation}")
      flash[:error] = "Script execution failed." unless success
    end

    def update_wifi_config
      wifi_config = Settings.wpa_supplicant_content
      script_path = Rails.root.join('..', 'scripts', 'update_wifi_config.sh')
      success = system("sudo #{script_path} '#{wifi_config}'")
      flash[:error] = "Script execution failed." unless success
    end
  end
end
