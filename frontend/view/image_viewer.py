import tkinter as tk
from PIL import Image, ImageTk

class SimpleImageViewer(tk.Frame):
    def __init__(self, parent):
        super().__init__(parent)
        self.pack(fill=tk.BOTH, expand=True)
        self.load_and_display_image()

    def load_and_display_image(self):
        image_path = 'assets/artwork.jpg'  # Update this path if needed

        try:
            # Load the image using PIL
            pil_image = Image.open(image_path)
            self.photo_image = ImageTk.PhotoImage(pil_image)

            # Create a canvas and display the image
            self.canvas = tk.Canvas(self, width=pil_image.width, height=pil_image.height, bg='black')
            self.canvas.pack()
            self.canvas.create_image(0, 0, anchor=tk.NW, image=self.photo_image)
        except Exception as e:
            print(f"Failed to load and display image: {e}")

def main():
    root = tk.Tk()
    root.title("Simple Image Viewer")
    app = SimpleImageViewer(root)
    root.mainloop()

if __name__ == "__main__":
    main()
