class UpframeUpdateService
  SCRIPT_DIR = "/home/upframe/upframeos/scripts"
  LOG_FILE = "/home/upframe/update.log"

  def self.update
    # Call the update script using the constant for the path
    system("#{SCRIPT_DIR}/update.sh >> #{LOG_FILE} 2>&1")
    if $?.success?
      system("sudo systemctl restart weston upframe &>> #{LOG_FILE}")
    end
  end
end