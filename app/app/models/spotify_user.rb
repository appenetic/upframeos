class SpotifyUser < ApplicationRecord
    serialize :auth_data, coder: JSON, type: Hash
end
