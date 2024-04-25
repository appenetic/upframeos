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
        update_chromium_config(value) if key == 'display_fps_meter'
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

    def update_chromium_config(display_fps)
      config_file_path = Rails.root.join('/home/upframe/upframeos/config/', 'chromium.conf')
      config = File.read(config_file_path)

      has_fps_counter = config.include?("--show-fps-counter")

      if display_fps && !has_fps_counter
        # Add `--show-fps-counter` if it's not present and `display_fps_meter` is true
        config << " --show-fps-counter"
      elsif !display_fps && has_fps_counter
        # Remove `--show-fps-counter` if it's present and `display_fps_meter` is false
        config = config.gsub(" --show-fps-counter", "")
      end

      File.write(config_file_path, config)
    end
  end
end
