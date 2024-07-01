import tkinter as tk
from widget.image_widget import ImageWidget
from lib.api_client import APIClient
import threading

class StartUpView(tk.Frame):
    def __init__(self, parent, api_client, on_startup_completed_callback, check_interval=5000):
        super().__init__(parent, bd=0, highlightthickness=0)
        self.parent = parent
        self.api_client = api_client
        self.on_startup_completed_callback = on_startup_completed_callback
        self.check_interval = check_interval  # in milliseconds
        
        image_widget = ImageWidget(self, 'assets/upframe.png', bg='black')
        image_widget.pack(fill=tk.BOTH, expand=True)
        
        self.after(self.check_interval, self.periodic_check)

    def periodic_check(self):
        # Move the API call to a thread to avoid freezing the UI
        thread = threading.Thread(target=self.check_status)
        thread.daemon = True
        thread.start()

    def check_status(self):
        is_online = self.api_client.get_boot_status()
        if is_online:
            # Invoke the callback in the main thread
            self.parent.after(0, self.on_startup_completed_callback)
        else:
            # Reschedule the next check in the main thread
            self.parent.after(self.check_interval, self.periodic_check)