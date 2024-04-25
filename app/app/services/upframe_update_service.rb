class UpframeUpdateService
  UPFRAMEOS_DIR = "/home/upframe/upframeos/"
  def self.update
    Dir.chdir(UPFRAMEOS_DIR) do
      # Perform a git pull to update the repository
      system("git pull")

      # Run database migrations in production environment
      system("RAILS_ENV=production rake db:migrate")

      # Precompile assets in production environment
      system("RAILS_ENV=production rake assets:precompile")

      # Restart Upframe service
      system("sudo systemctl restart upframe")

      # Restart Weston service
      system("sudo systemctl restart weston")
    end
  end
end
