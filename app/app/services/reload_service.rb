class ReloadService
  SCRIPT_DIR = "/home/upframe/upframeos/scripts"
  def self.reload
    system("#{SCRIPT_DIR}/reload.sh 2>&1")
  end
end
