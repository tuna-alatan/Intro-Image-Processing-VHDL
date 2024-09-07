import numpy as np
import cv2

def read_frames_from_txt(file_path, width, height, delimiter="FRAME_END"):
    frames = []
    with open(file_path, 'r') as file:
        next(file)
        frame_data = []
        for line in file:
            stripped_line = line.strip()
            if stripped_line == delimiter:
                # Convert frame data to a numpy array and reshape it
                pixel_values = [int(b, 2) for b in frame_data]
                frame = np.array(pixel_values, dtype=np.uint8).reshape((height, width))
                frames.append(frame)
                frame_data = []
            else:
                frame_data.extend(stripped_line.split())
    return frames

def display_video(frames, frame_rate):
    for frame in frames:
        cv2.imshow('Video from TXT', frame)
        if cv2.waitKey(int(1000 / frame_rate)) & 0xFF == ord('q'):
            break
    cv2.destroyAllWindows()

def main():
    file_path = "C:\\Users\\tuna\\Documents\\Staj2024\\test_pattern\\results.txt"  # Path to the text file containing binary pixel values
    width = 640  # Replace with the actual width of your frames
    height = 480  # Replace with the actual height of your frames
    frame_rate = 24  # Replace with the frame rate of your video

    frames = read_frames_from_txt(file_path, width, height)
    display_video(frames, frame_rate)

if __name__ == "__main__":
    main()
