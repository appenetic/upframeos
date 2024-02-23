class Artwork < ApplicationRecord
    has_one_attached :video
    has_one_attached :image
end
