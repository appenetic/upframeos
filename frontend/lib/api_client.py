# lib/api_client.py
import requests
from model.playing_status import PlayingStatus

class APIClient:
    def __init__(self, base_url):
        self.base_url = base_url

    def get_playing_status(self):
        url = f"{self.base_url}/playing_status"
        try:
            response = requests.get(url)
            response.raise_for_status()  # Raise an exception for HTTP errors
            json_data = response.json()
            return PlayingStatus.from_json(json_data)
        except requests.exceptions.RequestException as e:
            print(f"Error querying the API: {e}")
            return None
