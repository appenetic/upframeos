import tkinter as tk

class Hardware:
    def __init__(self):
        # Initialization code
        pass

    def get_screen_resolution():
        root = tk.Tk()
        root.withdraw()
        screen_width = root.winfo_screenwidth()
        screen_height = root.winfo_screenheight()

        return screen_width, screen_height
