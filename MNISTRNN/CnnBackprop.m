clear;
clc;

% Load MNIST Data
load('MNIST_TrainSet_0to1_8x8pixel.mat');
load('MNIST_TrainSet_Label.mat');

% CNN Parameters
NumOutput = 10;              % 10 output classes
filter_size = 3;              % 3x3 convolutional filter
NumFilters = 8;               % Number of filters in the conv layer
pool_size = 2;                % 2x2 pooling

% Hyperparameters
learning_rate = 0.1;          % Learning rate
num_samples = size(number, 2);
batch_size = 6000;            % Size of each batch
num_batches = 10;             % Total number of batches
accuracy_history = zeros(num_batches, 1); % Array to store accuracy

% Initialize Weights
rng(3);
conv_filters = rand(filter_size, filter_size, NumFilters) / 1e2; % 3x3 conv filters
fc_layer = (rand(NumFilters * 9 + 1, NumOutput)) / 1e2;          % Fully connected layer

% Loop over all images
for i = 1:num_samples
    % One-hot target
    target = zeros(1, 10);
    target(label(i) + 1) = 1;  % One-hot encoding for current digit

    %%%%%%%%%%%%%%% Forward Propagation %%%%%%%%%%%%%%%%
    input_image = reshape(number(:, i), [8, 8]);
    
    % Convolutional layer
    conv_out = zeros(6, 6, NumFilters);
    for k = 1:NumFilters
        conv_out(:, :, k) = conv2(input_image, conv_filters(:, :, k), 'valid');
    end
    conv_out = 1 ./ (1 + exp(-conv_out));  % Apply sigmoid activation

    % Pooling layer
    pooled_out = zeros(3, 3, NumFilters);
    for k = 1:NumFilters
        pooled_out(:, :, k) = max_pool(conv_out(:, :, k), pool_size);
    end

    % Flatten and Fully Connected Layer
    flattened = [pooled_out(:)' 1];  % Flatten and add bias term
    output_L2 = flattened * fc_layer;
    f = 1 ./ (1 + exp(-output_L2));   % Sigmoid activation for output
    derivative_L2 = exp(-output_L2) ./ (1 + exp(-output_L2)).^2; % Derivative

    %%%%%%%%%%%%%%% Backpropagation %%%%%%%%%%%%%%%%%%%%
    
    % Output layer error and gradient (fully connected layer)
    delta_L2 = (f - target) .* derivative_L2;
    gradient_fc = flattened' * delta_L2; % Gradient for fc_layer

    % Gradient back through flatten and pooling to conv layer
    delta_pooled = (delta_L2 * fc_layer(1:end-1, :)') .* flattened(1:end-1); % Remove bias term in fc_layer
    delta_conv = unpool(delta_pooled, conv_out, pool_size);  % Backprop through pooling

    % Gradient for conv filters
    gradient_conv = zeros(size(conv_filters));
    for k = 1:NumFilters
        gradient_conv(:, :, k) = conv2(input_image, delta_conv(:, :, k), 'valid');
    end

    %%%%%%%%%%%%%%%% Update Weights %%%%%%%%%%%%%%%%%%%%
    fc_layer = fc_layer - learning_rate * gradient_fc;
    conv_filters = conv_filters - learning_rate * gradient_conv;

    %%%%%%%%%%%%%%% Calculate Accuracy %%%%%%%%%%%%%%%
    
    % Calculate and store accuracy every 6000 images (1 batch)
    if mod(i, batch_size) == 0
        num_correct = 0;
        for k = (i - batch_size + 1):i
            % Forward Propagation for Accuracy Calculation
            input_image = reshape(number(:, k), [8, 8]);
            
            % Conv Layer
            conv_out = zeros(6, 6, NumFilters);
            for f = 1:NumFilters
                conv_out(:, :, f) = conv2(input_image, conv_filters(:, :, f), 'valid');
            end
            conv_out = 1 ./ (1 + exp(-conv_out)); % Activation
            
            % Pooling
            pooled_out = zeros(3, 3, NumFilters);
            for f = 1:NumFilters
                pooled_out(:, :, f) = max_pool(conv_out(:, :, f), pool_size);
            end
            
            % Fully Connected
            flattened = [pooled_out(:)' 1];
            output_L2 = flattened * fc_layer;
            f_pred = 1 ./ (1 + exp(-output_L2));  % Sigmoid for output
            
            [~, predicted_label] = max(f_pred);  % Get predicted label
            if predicted_label - 1 == label(k)   % Compare with true label
                num_correct = num_correct + 1;
            end
        end
        
        accuracy = (num_correct / batch_size) * 100;  % Calculate accuracy percentage
        accuracy_history(i / batch_size) = accuracy;  % Store accuracy
        fprintf('Accuracy after %d images: %.2f%%\n', i, accuracy);
    end
end

%%%%%%%%%%%%%%%%%%%%%% Graphs %%%%%%%%%%%%%%%%%%%%%%%%%%

% Plotting the accuracy over the number of batches
figure;
plot(1:num_batches, accuracy_history, '-o');
xlabel('Batch Number');
ylabel('Accuracy (%)');
title('Training Accuracy over Batches');
grid on;

%%%%%%%%%%%%%%%%%%%%%% Helper Functions %%%%%%%%%%%%%%%%%%%%%%

function pooled = max_pool(feature_map, pool_size)
    % Define the block size and the function to apply
    block_size = [pool_size pool_size];
    fun = @(block_struct) max(block_struct.data(:));
    
    % Apply blockproc to perform max pooling
    pooled = blockproc(feature_map, block_size, fun);
end

function delta_unpooled = unpool(delta_pooled, feature_map, pool_size)
    delta_unpooled = kron(delta_pooled, ones(pool_size)) .* (feature_map == kron(delta_pooled, ones(pool_size)));
end
