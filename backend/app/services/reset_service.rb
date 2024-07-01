class ResetService
  SCRIPT_DIR = "/home/upframe/upframeos/scripts"
  LOG_FILE = "/home/upframe/log.log"

  def self.reset
    system("#{SCRIPT_DIR}/reset_all_settings.sh >> #{LOG_FILE} 2>&1")
  end
end