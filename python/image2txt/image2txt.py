import cv2
import numpy as np

def convert_and_resize_image(input_image_path, output_txt_path, new_width, new_height):
    # Read the image
    image = cv2.imread(input_image_path)
    if image is None:
        print("Error: Could not open or find the image.")
        return
    
    # Convert the image to grayscale
    grayscale_image = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    
    # Resize the image to the specified dimensions
    resized_image = cv2.resize(grayscale_image, (new_width, new_height))
    
    # Write the resized image's pixel values to a text file in 8-bit binary format
    with open(output_txt_path, 'w') as file:
        for row in resized_image:
            for pixel in row:
                # Convert the pixel value to an 8-bit binary string
                binary_string = format(pixel, '08b')
                file.write(binary_string + '\n')

    
    print(f"Grayscale resized image has been written to {output_txt_path}")
    
     # Display the resized grayscale image
    cv2.imshow('Resized Grayscale Image', resized_image)
    cv2.waitKey(0)
    cv2.destroyAllWindows()
    
def test_pattern(width, height, output_txt_path):
    img = np.zeros((height, width), np.int16)
    
    for i in range(height):
        for j in range(width):
            if (j % 2 == 0):
                img[i, j] = 255
            else:
                img[i, j] = 0
                
    # Write the resized image's pixel values to a text file in 8-bit binary format
    with open(output_txt_path, 'w') as file:
        for row in img:
            for pixel in row:
                # Convert the pixel value to an 8-bit binary string
                binary_string = format(pixel, '08b')
                file.write(binary_string + '\n')

    
    print(f"Grayscale resized image has been written to {output_txt_path}")
    
     # Display the resized grayscale image
    cv2.imshow('Test Grayscale Image', img)
    cv2.waitKey(0)
    cv2.destroyAllWindows()

def main():
    input_image_path = 'dog.jpg'  # Replace with your image path
    output_txt_path = 'output_image.txt'  # Path to the output text file
    output_test_path = 'test_image.txt'  # Path to the output text file
    new_width = 640  # Replace with the desired width
    new_height = 480  # Replace with the desired height

    convert_and_resize_image(input_image_path, output_txt_path, new_width, new_height)
    #test_pattern(new_width, new_height, output_test_path)

if __name__ == "__main__":
    main()
