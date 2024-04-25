ActiveAdmin.register_page "Settings" do
  menu priority: 10, label: "Settings"

  content title: 'Settings' do
    settings = OpenStruct.new(
      orientation: Settings.orientation,
      wifi_country: Settings.wifi_country,
      wifi_ssid: Settings.wifi_ssid,
      wifi_password: Settings.wifi_password,
      canvas_feature_enabled: Settings.canvas_feature_enabled,
      developer_mode_enabled: Settings.developer_mode_enabled
    )
    render partial: 'layouts/admin/settings_form', locals: { settings_form: settings }
  end

  page_action :update_settings, method: :post do
    @errors = ActiveModel::Errors.new(Settings.new)

    pp permitted_params

    permitted_params.each do |key, value|
      next if value.blank?
      begin
        Settings.send("#{key}=", value.strip)
      rescue => e
        @errors.add(:base, "Failed to update setting '#{key}': #{e.message}")
      end
    end

    if @errors.any?
      flash[:error] = @errors.full_messages.join(", ")
      redirect_to admin_settings_path
    else
      redirect_to admin_settings_path, notice: "Settings were successfully updated."
    end
  end

  controller do
    def permitted_params
      params.require('[settings]').permit(:orientation, :wifi_country, :wifi_ssid, :wifi_password, :canvas_feature_enabled)
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
