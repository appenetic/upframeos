class PlayingStatus:
    def __init__(self, playing: bool):
        self.playing = playing

    @classmethod
    def from_json(cls, json_data):
        return cls(playing=json_data.get("playing", False))

    def __repr__(self):
        return f"PlayingStatus(playing={self.playing})"