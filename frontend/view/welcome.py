import tkinter as tk
from widget.video_widget import VideoWidget
from lib.api_client import APIClient

class WelcomeView(tk.Frame):
    def __init__(self, parent, on_configuration_completed):
        super().__init__(parent, bd=0, highlightthickness=0)
        self.parent = parent
        self.on_configuration_completed = on_configuration_completed
        
        video_widget = VideoWidget(self, 'assets/startup_background.mp4')
        video_widget.pack(fill=tk.BOTH, expand=True)