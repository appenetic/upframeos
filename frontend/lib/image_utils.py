import cv2

class ImageUtils:
    def resize_image_to_fit_screen(image, screen_width, screen_height):
        image_height, image_width = image.shape[:2]
        if image_width > screen_width or image_height > screen_height:
            scaling_factor = min(screen_width / image_width, screen_height / image_height)
            new_size = (int(image_width * scaling_factor), int(image_height * scaling_factor))
            image = cv2.resize(image, new_size, interpolation=cv2.INTER_AREA)
        return image