import tkinter as tk
from PIL import Image, ImageTk
import cv2
import os

class ImageWidget(tk.Canvas):
    def __init__(self, parent, image_path, *args, **kwargs):
        super().__init__(parent, *args, borderwidth=0, highlightthickness=0, **kwargs)
        self.image_path = image_path
        self.photo_image = None
        self.image_id = None  # Keep track of the image object on the canvas
        self.load_and_display_image()

    def load_and_display_image(self):
        # Check if the image file exists
        if not os.path.exists(self.image_path):
            print(f"Error: Image file {self.image_path} does not exist")
            return

        # Read the image
        image = cv2.imread(self.image_path, cv2.IMREAD_UNCHANGED)
        if image is None:
            print(f"Error: Could not load image {self.image_path}")
            return

        # Convert image from BGR to RGB
        image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)

        # Convert image to PIL format
        image = Image.fromarray(image)

        # Create PhotoImage from PIL image
        self.photo_image = ImageTk.PhotoImage(image)

        # Initialize the canvas image item
        self.image_id = self.create_image(0, 0, image=self.photo_image, anchor=tk.CENTER)
        
        # Redraw the image when the canvas size changes
        self.bind("<Configure>", self.update_image)

    def update_image(self, event=None):
        if self.photo_image:
            # Center the image
            width = self.winfo_width()
            height = self.winfo_height()
            self.coords(self.image_id, width / 2, height / 2)