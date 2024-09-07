import numpy as np
import cv2
import matplotlib.pyplot as plt

def gen_test_pattern(width, height):
    
    with open("results_py.txt", 'w') as file: 
    
        count = 0
        pixel_count = 0
    
        for i in range(width * height):
        
            
            
        
            # Convert the pixel value to an 8-bit binary string
            binary_string = format(count, '08b')
            # Write the binary string to the file
            file.write(binary_string + '\n')
            
            if (count == 255):
                count = 0
            else:
                count += 1
                
            if (pixel_count == width - 1):
                count = 0
                pixel_count = 0
            else:
                pixel_count += 1
                
                
def gen_diag_test_pattern(width, height):
    
    with open("results_py.txt", 'w') as file: 
    
        count = 0
        pixel_count = 0
        line_count = 0
        
        for i in range(height):
            for j in range(width):
                # Convert the pixel value to an 8-bit binary string
                binary_string = format(count, '08b')
                # Write the binary string to the file
                file.write(binary_string + '\n')
                
                if (count == 255):
                    count = 0
                else:
                    count += 1
            
            
            
            if (line_count == 255):
                line_count = 0
            else:
                line_count += 1
        
            count = line_count
   

def gen_horiz_test_pattern(width, height):
    
    with open("results_py.txt", 'w') as file: 
    

        line_count = 0
        
        for i in range(height):
            for j in range(width):
                # Convert the pixel value to an 8-bit binary string
                binary_string = format(line_count, '08b')
                # Write the binary string to the file
                file.write(binary_string + '\n')          
            
            if (line_count == 255):
                line_count = 0
            else:
                line_count += 1
   
        
def read_binary_file(file_path):
    with open(file_path, 'r') as file:
        lines = file.readlines()
    # Remove any extra whitespace and join lines into a single string
    binary_values = ''.join(line.strip() for line in lines).split()
    return binary_values

def compare_files(file1_path, file2_path):
    # Read the binary values from the two files
    binary_values1 = read_binary_file(file1_path)
    binary_values2 = read_binary_file(file2_path)

    # Check if both files have the same number of values
    if len(binary_values1) != len(binary_values2):
        print("The files have different lengths.")
        return

    differences = []
    for index, (val1, val2) in enumerate(zip(binary_values1, binary_values2)):
        if val1 != val2:
            differences.append(index)


    if differences:
        print(f"Files are different at positions: {differences}")
    else:
        print("Files are identical.")
        
def calculate_histogram(image):
    # Calculate the histogram for a grayscale image
    histogram = cv2.calcHist([image], [0], None, [256], [0, 256])
    return histogram

def calc_hist_man(image, width, height):
    hist = np.zeros(256)
    for i in range(height):
        for j in range(width):
            hist[image[i, j]] += 1
     
    return hist
def plot_histogram(histogram):
    # Plot the histogram using Matplotlib
    plt.figure()
    plt.title("Grayscale Histogram")
    plt.xlabel("Pixel Value")
    plt.ylabel("Frequency")
    plt.bar(range(256), histogram[:, 0], width=1)
    plt.xlim([0, 256])
    plt.show()

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

def display_image(image1, image2):
    # Display the image using OpenCV
    cv2.imshow('Image from TXT', image1)
    cv2.imshow('Image from TXT PY', image2)
    cv2.waitKey(0)
    cv2.destroyAllWindows()

def main():
    file_path_res = "C:\\Users\\tuna\\Documents\\Staj2024\\histogram\\histogram_results.txt" # Path to the text file containing pixel values
    file_path_res_gt = "C:\\Users\\tuna\\Documents\\Staj2024\\test_pattern\\results.txt" # Path to the text file containing pixel values
    file_path_res_py = "results_py.txt" # Path to the text file containing pixel values
    width = 640  # Replace with the actual width of your image
    height = 480  # Replace with the actual height of your image
    
    gen_diag_test_pattern(width, height)
    
    image = read_image_from_txt(file_path_res, width, height)  
    image_gt = read_image_from_txt(file_path_res_gt, width, height)  
    image_py = read_image_from_txt(file_path_res_py, width, height)
    
    hist = calc_hist_man(image, width, height)
    #hist = calculate_histogram(image)
    for i in range(len(hist)):
        print(int(hist[i]), end=' ')
        
        if ((i + 1) % 24 == 0):
            print('\n')
    
    display_image(image_py, image_gt)
    
    
    compare_files(file_path_res, file_path_res_gt)

if __name__ == "__main__":
    main()
