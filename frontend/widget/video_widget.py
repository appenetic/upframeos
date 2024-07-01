import cv2
import tkinter as tk

class VideoWidget:
    def __init__(self, root, video_path, loop=False):
        self.root = root
        self.video_path = video_path
        self.loop = loop
        self.play_video()

    def play_video(self):
        while True:
            # Open the video file
            cap = cv2.VideoCapture(self.video_path)
            
            # Check if the video was opened successfully
            if not cap.isOpened():
                print(f"Error: Could not open video {self.video_path}")
                return

            # Read and display frames from the video
            while cap.isOpened():
                ret, frame = cap.read()
                if not ret:
                    print("Restarting video")
                    break

                # Display the frame
                cv2.imshow('Video Playback', frame)

                # Wait for 25ms and check if the user pressed the 'q' key to quit
                if cv2.waitKey(25) & 0xFF == ord('q'):
                    cap.release()
                    cv2.destroyAllWindows()
                    return

            # Release the video capture object and close all OpenCV windows
            cap.release()