clear;
clc;

% 64-54-10 DNN Structure
NumInput = 64;
NumHidden = 50;
NumOutput = 10;

% Load MNIST Data
load('MNIST_TrainSet_0to1_8x8pixel.mat');
load('MNIST_TrainSet_Label.mat');

% Initialize Random Weights
rng(3);
layer1 = (rand(NumInput + 1, NumHidden) - 0.0) / 1e2;
layer2 = (rand(NumHidden + 1, NumOutput) - 0.0) / 1e2;

% Hyperparameters
learning_rate = 0.1; % Learning rate

% Total samples
num_samples = size(number, 2);
batch_size = 6000;    % Size of each batch
num_batches = 10;     % Total number of batches
accuracy_history = zeros(num_batches, 1); % Array to store accuracy


% Loop over all images
for i = 1:num_samples
    % One-hot target
    target = zeros(1, 10);
    target(label(i) + 1) = 1;  % One-hot encoding for current digit

    %%%%%%%%%%%%%%% Original Forward Propagation %%%%%%%%%%%%%%%%
    s1=number(:,1)';
    output_L1=[s1 1]*layer1;
    activity_L1=1./(1+exp(-output_L1));
    derivative_L1=exp(-output_L1)./(1+exp(-output_L1)).^2; % 1st derivative of the activity function
   
    output_L2=[activity_L1 1]*layer2;
    f=1./(1+exp(-output_L2));
    derivative_L2=exp(-output_L2)./(1+exp(-output_L2)).^2; % 1st derivative of the activity function            

    %%%%%%%%%%%%%%% Backpropagation %%%%%%%%%%%%%%%%%%%%
    
    % Output layer error and gradient (layer 2)
    delta_L2 = (f - target) .* derivative_L2;
    gradient_layer2 = [activity_L1 1]' * delta_L2;  % Gradient for layer 2

    % Hidden layer error and gradient (layer 1)
    delta_L1 = (delta_L2 * layer2(1:end-1,:)') .* derivative_L1;
    gradient_layer1 = [s1 1]' * delta_L1;  % Gradient for layer 1

    %%%%%%%%%%%%%%%% Update Weights %%%%%%%%%%%%%%%%%%%%
    layer2 = layer2 - learning_rate * gradient_layer2;
    layer1 = layer1 - learning_rate * gradient_layer1;

    %%%%%%%%%%%%%%% Calculate Accuracy %%%%%%%%%%%%%%%

    % Calculate and store accuracy every 6000 images (1 batch)
    if mod(i, batch_size) == 0
        num_correct = 0;
        for k = (i - batch_size + 1):i
            % Forward Propagation for Accuracy Calculation
            output_L1 = [number(:, k)' 1] * layer1;
            activity_L1=1./(1+exp(-output_L1));
            output_L2 = [activity_L1 1] * layer2;
            f_pred = 1./(1+exp(-output_L2));

            [~, predicted_label] = max(f_pred);  % Get predicted label
            if predicted_label - 1 == label(k)  % Compare with true label
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
