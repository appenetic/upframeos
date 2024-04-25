class UpframeUpdateService
  UPFRAMEOS_DIR = "/home/upframe/upframeos/"
  LOG_FILE = "/home/upframe/update.log"

  def self.update
    Dir.chdir(UPFRAMEOS_DIR) do
      # Perform a git pull to update the repository and log output
      system("git pull >> #{LOG_FILE} 2>&1")

      # Run database migrations in production environment and log output
      system("RAILS_ENV=production rake db:migrate >> #{LOG_FILE} 2>&1")

      # Precompile assets in production environment and log output
      system("RAILS_ENV=production rake assets:precompile >> #{LOG_FILE} 2>&1")

      # Restart Upframe service and log output
      system("sudo systemctl restart upframe weston >> #{LOG_FILE} 2>&1")
    end
  end
end
