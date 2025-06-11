imagePath = 'Users/w1ndm4rk/Documents/MATLAB/8x8GrayScaleImgs/Digit0.png'; % Change to your image path

% Read the image
img = imread(imagePath);

% Check if the image is RGB and convert to grayscale if necessary
if size(img, 3) == 3
    img = rgb2gray(img); % Convert to grayscale
end

% Resize the image to 8x8 (if not already)
img = imresize(img, [8, 8]);

% Convert the image to double for processing
img = double(img);

% Optionally, normalize the values to the range [0, 1]
img = img / 255; % If you want values between 0 and 1
% Or, to keep values as integers between 0 and 255, skip normalization.

% Reshape the image into a vector
vectorArray = img(:); % Convert to a column vector

% Display the vector array
disp('Vector Array:');
disp(vectorArray);

% Save the vector to a .mat file if needed
save('vectorArray.mat', 'vectorArray')