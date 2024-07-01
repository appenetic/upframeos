import tkinter as tk
from PIL import Image, ImageTk
import cv2
import os

class StartUpView(tk.Frame):
    def __init__(self, parent):
        super().__init__(parent)
        self.canvas = tk.Canvas(self, bg='black', width=800, height=600)
        self.canvas.pack(fill=tk.BOTH, expand=True)
        self.button = tk.Button(self, text="Continue", command=self.on_button_click)
        self.button.pack(pady=20)

    def on_button_click(self):
        print("Button was clicked!")

    def render(self):
        # Image path
        image_path = 'assets/artwork.jpg'

        # Check if the image file exists
        if not os.path.exists(image_path):
            print(f"Error: Image file {image_path} does not exist")
            return

        # Read the image
        print(f"Reading image from {image_path}")
        image = cv2.imread(image_path, cv2.IMREAD_UNCHANGED)
        if image is None:
            print(f"Error: Could not load image {image_path}")
            return

        print("Image loaded successfully")

        # Convert image from BGR to RGB
        image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
        print("Image converted from BGR to RGB")

        # Convert image to PIL format
        image = Image.fromarray(image)
        print("Image converted to PIL format")

        # Create PhotoImage from PIL image
        self.photo_image = ImageTk.PhotoImage(image)
        print("PhotoImage created successfully")

        # Display the image on the canvas, centered
        self.canvas.create_image(0, 0, anchor=tk.NW, image=self.photo_image)
        self.canvas.image = self.photo_image  # Keep a reference to avoid garbage collection
        print("Image displayed on canvas")

        # Force update the canvas
        self.canvas.update()
        self.update_idletasks()