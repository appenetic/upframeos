require_relative '../services/chromium_configuration_service'

ActiveAdmin.register_page "Developer" do
  menu priority: 4, label: "Developer", if: proc { DeveloperSettings.find_by(var: :developer_mode_enabled).value }

  content title: 'Developer' do
    settings = OpenStruct.new(
      developer_mode_enabled: DeveloperSettings.find_by(var: :developer_mode_enabled).value,
      display_fps_meter: DeveloperSettings.find_by(var: :display_fps_meter).value
    )

    render partial: 'layouts/admin/developer_form', locals: { settings_form: settings }
  end

  page_action :update_developer, method: :post do
    DeveloperSettings.developer_mode_enabled = ActiveRecord::Type::Boolean.new.cast(permitted_params[:developer_mode_enabled].to_i)
    DeveloperSettings.display_fps_meter = ActiveRecord::Type::Boolean.new.cast(permitted_params[:display_fps_meter].to_i)

    redirect_to admin_developer_path, notice: "Settings were successfully updated."
  end

  controller do
    before_action :load_system_info, only: [:index]
    def load_system_info
      @system_info = system_information
    end

    def permitted_params
      params.require('[settings]').permit(
        :developer_mode_enabled,
        :display_fps_meter
      )
    end

    def system_information
      cpu_temp_output = `cat /sys/devices/virtual/thermal/thermal_zone0/temp`
      cpu_temperature = cpu_temp_output.to_i / 1000.0

      uptime_output = `uptime`
      uptime = uptime_output.split(',')[0].split('up ')[1].strip

      { cpu_temperature: cpu_temperature, uptime: uptime }
    end

    def toggle_display_fps_counter(display_fps_counter)
      params_to_update = { '--show-fps-counter' => display_fps_counter }
      ChromiumConfigurationService.update_config(params_to_update)
    end
  end
end
