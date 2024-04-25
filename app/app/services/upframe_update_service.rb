class UpframeUpdateService
  SCRIPT_DIR = "/home/upframe/upframeos/scripts"
  LOG_FILE = "/home/upframe/update.log"

  def self.update
    system("#{SCRIPT_DIR}/update.sh >> #{LOG_FILE} 2>&1")
    case $?.exitstatus
    when 0
      :no_updates
    when 2
      system("sudo systemctl restart weston upframe &>> #{LOG_FILE}")
      :updates_applied
    else
      :failed
    end
  end
end
