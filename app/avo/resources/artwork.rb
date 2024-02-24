class Avo::Resources::Artwork < Avo::BaseResource
  self.includes = []
  self.default_view_type = :grid

  self.grid_view = {
    card: -> do
      {
        cover_url: record.url,
        title: record.title,
        body: record.duration
      }
    end
  }

  def fields
    field :video, as: :file
    field :image, as: :file
    field :duration, as: :number
  end
end
