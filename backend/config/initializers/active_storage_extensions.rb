Rails.application.config.to_prepare do
  ActiveStorage::Attachment.class_eval do
    def self.ransackable_attributes(auth_object = nil)
      # Adjust the list as necessary for your application needs.
      ["blob_id", "created_at", "id", "name", "record_id", "record_type"]
    end
  end
end