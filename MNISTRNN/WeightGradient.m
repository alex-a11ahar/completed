clear;
clc;

% 64-50-10 DNN Structure
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

% Hyperparameters
learning_rate = 0.01; % Learning rate
epsilon = 1e-4;       % Perturbation size

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
    s1 = number(:, i)';
    [f, activity_L1] = forward_propagation(s1, layer1, layer2);
   
    % Calculate Original Loss
    target = zeros(1, 10);
    target(digit + 1) = 1; % One-hot encoding target for the current digit
    Eref = calculate_loss(f, target);
   
    % Initialize gradients
    gradient_layer1 = zeros(size(layer1));
    gradient_layer2 = zeros(size(layer2));

    % Weight Perturbation for Layer 2
    for j = 1:numel(layer2)
        % Perturb the weight positively
        layer2_perturbed = layer2;
        layer2_perturbed(j) = layer2_perturbed(j) + epsilon;
        f_pos = forward_propagation(s1, layer1, layer2_perturbed);
        Epos = calculate_loss(f_pos, target);
        
        % Perturb the weight negatively
        layer2_perturbed(j) = layer2(j) - epsilon;
        f_neg = forward_propagation(s1, layer1, layer2_perturbed);
        Eneg = calculate_loss(f_neg, target);
        
        % Approximate gradient for this weight
        gradient_layer2(j) = (Epos - Eneg) / (2 * epsilon);
    end

    % Weight Perturbation for Layer 1
    for j = 1:numel(layer1)
        % Perturb the weight positively
        layer1_perturbed = layer1;
        layer1_perturbed(j) = layer1_perturbed(j) + epsilon;
        [f_pos, ~] = forward_propagation(s1, layer1_perturbed, layer2);
        Epos = calculate_loss(f_pos, target);
        
        % Perturb the weight negatively
        layer1_perturbed(j) = layer1(j) - epsilon;
        [f_neg, ~] = forward_propagation(s1, layer1_perturbed, layer2);
        Eneg = calculate_loss(f_neg, target);
        
        % Approximate gradient for this weight
        gradient_layer1(j) = (Epos - Eneg) / (2 * epsilon);
    end

    % Update Weights using Perturbation-based Gradient
    layer2 = layer2 - learning_rate * gradient_layer2;
    layer1 = layer1 - learning_rate * gradient_layer1;
   
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
