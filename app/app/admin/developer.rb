require_relative '../services/chromium_configuration_service'

ActiveAdmin.register_page "Developer" do
  menu priority: 3, label: "Developer", if: proc { Settings.developer_mode_enabled }

  content title: 'Developer' do
    settings = OpenStruct.new(
      developer_mode_enabled: Settings.developer_mode_enabled,
      display_fps_meter: Settings.display_fps_meter
    )

    render partial: 'layouts/admin/developer_form', locals: { settings_form: settings }
  end

  page_action :update_developer, method: :post do
    @errors = ActiveModel::Errors.new(Settings.new)

    permitted_params.each do |key, value|
      begin
        Settings.send("#{key}=", value)
        toggle_display_fps_counter(value) if key == 'display_fps_meter'
      rescue => e
        @errors.add(:base, "Failed to update setting '#{key}': #{e.message}")
      end
    end

    if @errors.any?
      flash[:error] = @errors.full_messages.join(", ")
      redirect_to admin_developer_path
    else
      redirect_to admin_developer_path, notice: "Settings were successfully updated."
    end
  end

  controller do
    before_action :load_system_info, only: [:index]
    def load_system_info
      @system_info = system_information
    end

    def permitted_params
      params.require('[settings]').permit(:developer_mode_enabled, :display_fps_meter).transform_values do |value|
        ActiveRecord::Type::Boolean.new.cast(value)
      end
    end

    def system_information
      cpu_temp_output = `cat /sys/devices/virtual/thermal/thermal_zone0/temp`
      cpu_temperature = cpu_temp_output.to_i / 1000.0

      { cpu_temperature: cpu_temperature }
    end

    def toggle_display_fps_counter(display_fps_counter)
      params_to_update = { '--show-fps-counter' => display_fps_counter }
      ChromiumConfigService.update_config(params_to_update)
    end
  end
end
