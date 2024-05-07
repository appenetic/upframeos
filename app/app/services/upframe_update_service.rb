class UpframeUpdateService
  SCRIPT_DIR = "/home/upframe/upframeos/scripts"
  def self.update
    system("#{SCRIPT_DIR}/update.sh 2>&1")
    case $?.exitstatus
    when 0
      :no_updates
    when 2
      system("sudo systemctl restart weston upframe")
      :updates_applied
    else
      :failed
    end
  end
end
