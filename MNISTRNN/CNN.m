clear;
clc;

% Load MNIST Data
load('MNIST_TrainSet_0to1_8x8pixel.mat');
load('MNIST_TrainSet_Label.mat');

% Parameters
NumOutput = 10;          % 10 output classes (digits 0 to 9)
filter_size = 3;         % 3x3 convolutional filter
NumFilters = 8;          % Number of filters in the conv layer
learning_rate = 0.01;    % Learning rate
epsilon = 1e-4;          % Perturbation size

% Initialize Random Weights for Convolutional Filters and Fully Connected Layer
rng(3);
conv_filters = rand(filter_size, filter_size, NumFilters) / 1e2; % 3x3 conv filters
fc_layer = (rand(NumFilters * 16 + 1, NumOutput)) / 1e2;         % Fully connected layer

% Loop over digit labels from 0 to 9
for digit = 0:9
    % Find the indices of images that correspond to the current digit
    indices = find(label == digit);
    
    % For simplicity, use the first image found for each digit
    if isempty(indices)
        continue;
    end
    i = indices(1);
    
    % Original Forward Propagation
    input_image = reshape(number(:, i), [8, 8]);
    [conv_out, fc_out] = cnn_forward(input_image, conv_filters, fc_layer);
    
    % Calculate Original Loss
    target = zeros(1, 10);
    target(digit + 1) = 1; % One-hot encoding target for the current digit
    Eref = calculate_loss(fc_out, target);
    
    % Initialize gradients
    gradient_conv = zeros(size(conv_filters));
    gradient_fc = zeros(size(fc_layer));

    % Perturbation for Fully Connected Layer
    for j = 1:numel(fc_layer)
        % Perturb weight positively
        fc_layer_perturbed = fc_layer;
        fc_layer_perturbed(j) = fc_layer_perturbed(j) + epsilon;
        [~, fc_pos] = cnn_forward(input_image, conv_filters, fc_layer_perturbed);
        Epos = calculate_loss(fc_pos, target);
        
        % Perturb weight negatively
        fc_layer_perturbed(j) = fc_layer(j) - epsilon;
        [~, fc_neg] = cnn_forward(input_image, conv_filters, fc_layer_perturbed);
        Eneg = calculate_loss(fc_neg, target);
        
        % Approximate gradient
        gradient_fc(j) = (Epos - Eneg) / (2 * epsilon);
    end

    % Perturbation for Convolutional Layer
    for j = 1:numel(conv_filters)
        % Perturb filter positively
        conv_filters_perturbed = conv_filters;
        conv_filters_perturbed(j) = conv_filters_perturbed(j) + epsilon;
        [conv_pos, ~] = cnn_forward(input_image, conv_filters_perturbed, fc_layer);
        Epos = calculate_loss(conv_pos, target);
        
        % Perturb filter negatively
        conv_filters_perturbed(j) = conv_filters(j) - epsilon;
        [conv_neg, ~] = cnn_forward(input_image, conv_filters_perturbed, fc_layer);
        Eneg = calculate_loss(conv_neg, target);
        
        % Approximate gradient
        gradient_conv(j) = (Epos - Eneg) / (2 * epsilon);
    end

    % Update Weights
    fc_layer = fc_layer - learning_rate * gradient_fc;
    conv_filters = conv_filters - learning_rate * gradient_conv;
    
    % Visualization of Gradients
    figure;
    subplot(1, 2, 1);
    imagesc(input_image);
    axis('square');
    title(['Input Image - Digit ', num2str(digit)]);
    
    subplot(1, 2, 2);
    imagesc(gradient_conv(:, :, 1), [-1e-3, 1e-3]); % Show gradient of first filter
    axis('square');
    title(['Gradient Visualization - Conv Filter - Digit ', num2str(digit)]);
end

% Function Definitions
function [conv_out, fc_out] = cnn_forward(input_image, conv_filters, fc_layer)
    % Convolutional Layer
    [filter_size, ~, NumFilters] = size(conv_filters);
    conv_out = zeros(6, 6, NumFilters);
    for k = 1:NumFilters
        conv_out(:, :, k) = conv2(input_image, conv_filters(:, :, k), 'valid');
    end
    conv_out = 1 ./ (1 + exp(-conv_out)); % Apply activation function
    
    % Flatten and Fully Connected Layer
    flattened = [conv_out(:)', 1]; % Flatten and add bias term
    fc_out = 1 ./ (1 + exp(-flattened * fc_layer)); % Fully connected output
end

function E = calculate_loss(fc_out, target)
    E = sum((fc_out - target) .^ 2) / 2;
end
