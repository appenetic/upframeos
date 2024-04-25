class UpframeUpdateService
  SCRIPT_DIR = "/home/upframe/upframeos/scripts"
  LOG_FILE = "/home/upframe/update.log"

  def self.update
    system("#{SCRIPT_DIR}/update.sh >> #{LOG_FILE} 2>&1")
    if $?.exitstatus == 2
      system("sudo systemctl restart weston upframe &>> #{LOG_FILE}")
    end
    $?.success?
  end
end
