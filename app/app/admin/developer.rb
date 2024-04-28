require_relative '../services/chromium_configuration_service'
require_relative '../services/system_info_service'

ActiveAdmin.register_page "Developer" do
  menu priority: 4, label: "Developer", if: proc { DeveloperSettings.find_by(var: :developer_mode_enabled).value }

  content title: 'Developer' do
    settings = controller.load_developer_settings

    render partial: 'layouts/admin/developer_form', locals: { settings_form: settings }
  end

  page_action :update_developer, method: :post do
    original_developer_settings = load_developer_settings
    DeveloperSettings.developer_mode_enabled = ActiveRecord::Type::Boolean.new.cast(permitted_params[:developer_mode_enabled].to_i)
    DeveloperSettings.display_fps_meter = ActiveRecord::Type::Boolean.new.cast(permitted_params[:display_fps_meter].to_i)
    updated_developer_settings = load_developer_settings

    if original_developer_settings.display_fps_meter != updated_developer_settings.display_fps_meter
      toggle_display_fps_counter(updated_developer_settings.display_fps_meter)
    end

    redirect_to admin_developer_path, notice: "Settings were successfully updated."
  end

  controller do
    before_action :load_system_info, only: [:index]
    def load_system_info
      system_info_service = SystemInfoService.new
      @system_info = system_info_service.fetch_system_info
    end

    def permitted_params
      params.require('[settings]').permit(
        :developer_mode_enabled,
        :display_fps_meter
      )
    end

    def load_developer_settings
      OpenStruct.new(
        developer_mode_enabled: DeveloperSettings.find_by(var: :developer_mode_enabled).value,
        display_fps_meter: DeveloperSettings.find_by(var: :display_fps_meter).value
      )
    end

    def toggle_display_fps_counter(display_fps_counter)
      params_to_update = { '--show-fps-counter' => display_fps_counter }
      ChromiumConfigurationService.update_config(params_to_update)
    end
  end
end
