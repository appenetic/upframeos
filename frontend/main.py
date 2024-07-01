import tkinter as tk
from view.startup import StartUpView

class MainApp:
    def __init__(self):
        self.window = tk.Tk()
        self.window.title('UpFrame Frontend')
        self.window.attributes('-fullscreen', True)
        
    def run(self):
        self.window.mainloop()

if __name__ == "__main__":
    app = MainApp()
    app.run()
