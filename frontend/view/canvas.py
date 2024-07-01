import tkinter as tk
from tkinter import ttk
from PIL import Image, ImageTk
import cv2
from lib.hardware import Hardware
from lib.image_utils import ImageUtils

class CanvasView(ttk.Frame):
    def __init__(self, parent):
        super().__init__(parent)
        self.canvas = tk.Canvas(self, bg='black')
        self.canvas.pack(fill=tk.BOTH, expand=True)

    def render(self):
        # Image path
        image_path = 'assets/artwork.jpg'
        
        # Read the image
        image = cv2.imread(image_path, cv2.IMREAD_UNCHANGED)
        if image is None:
            print(f"Error: Could not load image {image_path}")
            return

        # Get screen resolution dynamically
        screen_width, screen_height = Hardware.get_screen_resolution()

        # Resize the image if necessary
        image = ImageUtils.resize_image_to_fit_screen(image, screen_width, screen_height)

        # Convert image from BGR to RGB
        image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)

        # Convert image to PIL format
        image = Image.fromarray(image)

        # Create PhotoImage from PIL image
        self.photo_image = ImageTk.PhotoImage(image)

        # Display the image on the canvas
        self.canvas.create_image(0, 0, anchor=tk.NW, image=self.photo_image)
        self.canvas.image = self.photo_image  # Keep a reference to avoid garbage collection
