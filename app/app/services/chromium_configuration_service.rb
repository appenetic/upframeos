class ChromiumConfigService
  CONFIG_FILE_PATH = Rails.root.join('/home/upframe/upframeos/config', 'chromium.conf')

  # Updates the configuration with given parameters
  def self.update_config(params)
    config = File.read(CONFIG_FILE_PATH)
    needs_update = false

    params.each do |param, value|
      regex = /#{Regexp.escape(param)}/

      # Check if the parameter is currently included in the config
      has_param = config.match?(regex)

      if value && !has_param
        # Add the parameter before --kiosk if it's not present
        config.sub!(/--kiosk/, "#{param} --kiosk")
        needs_update = true
      elsif !value && has_param
        # Remove the parameter if it should no longer be present
        config.gsub!(regex, '')
        needs_update = true
      end
    end

    if needs_update
      # Clean up any double spaces that might have been created
      config.gsub!(/\s+/, ' ')
      # Write the updated config back to the file
      File.write(CONFIG_FILE_PATH, config)
      # Execute system command to restart Weston
      system('sudo systemctl restart weston')
    end
  end
end
