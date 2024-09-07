import cv2
import numpy as np
import matplotlib.pyplot as plt
import math

def bilinear_interpolation(image, new_width, new_height):
    original_height, original_width = image.shape

    resized_image = np.zeros((new_height, new_width), dtype=np.uint8)

    x_ratio = float(original_width - 1) / (new_width - 1) if new_width > 1 else 0
    y_ratio = float(original_height - 1) / (new_height - 1) if new_height > 1 else 0

    for i in range(new_height):
        for j in range(new_width):
            x_l, y_l = math.floor(x_ratio * j), math.floor(y_ratio * i)
            x_h, y_h = math.ceil(x_ratio * j), math.ceil(y_ratio * i)

            x_weight = (x_ratio * j) - x_l
            y_weight = (y_ratio * i) - y_l

            a = image[y_l, x_l]
            b = image[y_l, x_h]
            c = image[y_h, x_l]
            d = image[y_h, x_h]

            pixel_value = (a * (1 - x_weight) * (1 - y_weight) +
                           b * x_weight * (1 - y_weight) +
                           c * (1 - x_weight) * y_weight +
                           d * x_weight * y_weight)

            resized_image[i, j] = int(pixel_value)

    return resized_image
    
def read_image_from_txt(file_path, width, height):
    # Read the binary pixel values from the text file
    with open(file_path, 'r') as file:
        pixel_values = file.read().split()
    
    # Convert binary strings to integers
    pixel_values = [int(b, 2) for b in pixel_values]
    
    # Convert the list to a numpy array
    pixel_array = np.array(pixel_values, dtype=np.uint8)
    
    # Reshape the array to the specified width and height
    image = pixel_array.reshape((height, width))
    
    return image

def main():
    input_image_path = 'dog.jpg'  # Replace with your image path
    vhdl_image_path = "C:\\Users\\tuna\\Documents\\Staj2024\\bl_interp\\bl_interp_results.txt"  # Replace with your image path
    new_width = 300  # Replace with the desired width
    new_height = 480  # Replace with the desired height

    # Read the image
    image = cv2.imread(input_image_path, cv2.IMREAD_GRAYSCALE)
    if image is None:
        print("Error: Could not open or find the image.")
        return

    # Resize the image using bilinear interpolation
    resized_image = bilinear_interpolation(image, 640, 480)
    vhdl_image = read_image_from_txt(vhdl_image_path, new_width, new_height)

    # Display the original and resized images using Matplotlib
    plt.figure(figsize=(10, 5))
    plt.subplot(1, 2, 1)
    plt.title('Python Image')
    plt.imshow(resized_image, cmap='gray', vmin=0, vmax=255)

    plt.subplot(1, 2, 2)
    plt.title('VHDL Image')
    plt.imshow(vhdl_image, cmap='gray', vmin=0, vmax=255)

    plt.show()

if __name__ == "__main__":
    main()
