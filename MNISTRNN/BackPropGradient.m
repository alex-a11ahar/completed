clear;
clc;

% 64-54-10 DNN Structure
NumInput = 64;
NumHidden = 50;
NumOutput = 10;
MatrixSize = NumInput + 1 + NumHidden + 1 + NumOutput;

% Load MNIST Data
load('MNIST_TrainSet_0to1_8x8pixel.mat');
load('MNIST_TrainSet_Label.mat');

% Initialize Random Weights
rng(3);
layer1 = (rand(NumInput + 1, NumHidden) - 0.0) / 1e2;
layer2 = (rand(NumHidden + 1, NumOutput) - 0.0) / 1e2;

% Gradient Matrix for visualization during training
gradientMatrix_dummy = zeros(MatrixSize, MatrixSize);
gradientMatrix_dummy(1:NumInput+1, NumInput+2:NumInput+2+NumHidden-1) = 1;
gradientMatrix_dummy(NumInput+2:NumInput+2+NumHidden, NumInput+1+NumHidden+1+1:NumInput+1+NumHidden+1+NumOutput) = 1;

% Loop over image labels from 0 to 9
for digit = 0:9
    % Find the indices of images that correspond to the current digit
    indices = find(label == digit);
   
    % For simplicity, use the first image found for each digit
    if isempty(indices)
        continue;
    end
    i = indices(1);
   
    % Original Forward Propagation
    s1 = number(:, i)';
    [f, activity_L1] = forward_propagation(s1, layer1, layer2);
   
    % Calculate Original Loss
    target = zeros(1, 10);
    target(digit + 1) = 1; % One-hot encoding target for the current digit
    Eref = calculate_loss(f, target);
   
    % Backpropagation to compute gradients
    % Gradient of loss with respect to the output layer
    delta_output = (f - target) .* f .* (1 - f);
   
    % Gradient for layer2 (between hidden layer and output layer)
    gradient_layer2 = [activity_L1 1]' * delta_output;
   
    % Backpropagation to the hidden layer
    delta_hidden = (delta_output * layer2(1:end-1,:)') .* activity_L1 .* (1 - activity_L1);
   
    % Gradient for layer1 (between input layer and hidden layer)
    gradient_layer1 = [s1 1]' * delta_hidden;
   
    % Visualization of Gradients
    figure;
    subplot(1, 2, 1);
    imagesc(transpose(reshape(number(:, i)', [8, 8])));
    axis('square');
    title(['Input Image - Digit ', num2str(digit)]);
   
    subplot(1, 2, 2);
    imagesc(gradient_layer1, [-1e-3, 1e-3]);
    axis('square');
    title(['Gradient Visualization - Layer 1 - Digit ', num2str(digit)]);
end

% Function Definitions
function [f, activity_L1] = forward_propagation(s1, layer1, layer2)
    output_L1 = [s1 1] * layer1;
    activity_L1 = 1 ./ (1 + exp(-output_L1));
    output_L2 = [activity_L1 1] * layer2;
    f = 1 ./ (1 + exp(-output_L2));
end

function E = calculate_loss(f, target)
    E = sum((f - target) .^ 2) / 2;
end