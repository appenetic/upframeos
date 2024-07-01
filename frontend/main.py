import tkinter as tk
from lib.api_client import APIClient
from view.startup import StartUpView
from view.welcome import WelcomeView

class MainApp:
    def __init__(self):
        self.window = tk.Tk()
        self.window.title('UpFrame Frontend')
        self.window.attributes('-fullscreen', True)
        self.window.configure(background='black')
        
        self.api_client = APIClient("http://localhost:3000")

        self.startup_view = StartUpView(self.window, self.api_client, self.on_startup_completed) 
        self.startup_view.pack(fill='both', expand=True)
    
    def on_startup_completed(self):
        self.startup_view.pack_forget()
        
        self.welcome_view = WelcomeView(self.window, self.on_setup_completed)
        self.welcome_view.pack(fill='both', expand=True)
        

        
    def on_setup_completed(self):
        self.window.title('Application Ready')
        

    def run(self):
        self.window.mainloop()

if __name__ == "__main__":
    app = MainApp()
    app.run()