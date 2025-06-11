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
epsilon = 0.2;       % Perturbation size

% Total samples
num_samples = size(number, 2);
sample_count = 0;     % Counter for samples processed
batch_size = 6000;    % Size of each batch
num_batches = 10; % Total number of batches
accuracy_history = zeros(num_batches, 1); % Array to store accuracy


% Error Function
function E = calculate_loss(f, T)
    E = sum((f - T) .^ 2) / 2;  % Mean squared error loss
end

% Loop over all images
for i = 1:num_samples
   
    % One-hot target
    target = zeros(1, 10);
    target(label(i) + 1) = 1;  % One-hot encoding for current digit

    %%%%%%%%%%%%%%% Original Forward Propagation %%%%%%%%%%%%%%%%
    s1=number(:,1)';
    output_L1=[s1 1]*layer1;
    activity_L1=1./(1+exp(-output_L1));
   
    output_L2=[activity_L1 1]*layer2;
    f=1./(1+exp(-output_L2));

    
    % Calculate initial loss
    Eref = calculate_loss(f, target);
    
    % Initialize gradients
    gradient_layer1 = zeros(size(layer1));
    gradient_layer2 = zeros(size(layer2));
    
    %%%%%%%%%%%%%% Weight Perturbation Layer 2 %%%%%%%%%%%%%%%%%%%%

    for j = 1:numel(layer2)
        % Perturb the weight positively
        layer2_perturbed = layer2;
        layer2_perturbed(j) = layer2_perturbed(j) + epsilon;
        
        % Forward Propagation
        output_L1=[s1 1]*layer1;
        activity_L1=1./(1+exp(-output_L1));
        
        output_L2=[activity_L1 1]*layer2_perturbed;
        f_pos=1./(1+exp(-output_L2));
      
        Epos = calculate_loss(f_pos, target);
        
        % Perturb the weight negatively
        layer2_perturbed(j) = layer2(j) - epsilon;
        
        % Forward Propagation
        output_L1=[s1 1]*layer1;
        activity_L1=1./(1+exp(-output_L1));
        
        output_L2=[activity_L1 1]*layer2_perturbed;
        f_neg=1./(1+exp(-output_L2));

        Eneg = calculate_loss(f_neg, target);
        
        % Approximate gradient for this weight
        gradient_layer2(j) = (Epos - Eneg) / (2 * epsilon);
    end

    %%%%%%%%%%%%% Weight Perturbation Layer 1 %%%%%%%%%%%%%%%%%

    for j = 1:numel(layer1)
        % Perturb the weight positively
        layer1_perturbed = layer1;
        layer1_perturbed(j) = layer1_perturbed(j) + epsilon;
        
        % Forward Propagation
        output_L1=[s1 1]*layer1_perturbed;
        activity_L1=1./(1+exp(-output_L1));
       
        output_L2=[activity_L1 1]*layer2;
        f_pos=1./(1+exp(-output_L2));
        
        Epos = calculate_loss(f_pos, target);
        
        % Perturb the weight negatively
        layer1_perturbed(j) = layer1(j) - epsilon;

        % Forward Propagation
        output_L1=[s1 1]*layer1_perturbed;
        activity_L1=1./(1+exp(-output_L1));
       
        output_L2=[activity_L1 1]*layer2;
        f_neg=1./(1+exp(-output_L2));
        
        Eneg = calculate_loss(f_neg, target);
        
        % Approximate gradient for this weight
        gradient_layer1(j) = (Epos - Eneg) / (2 * epsilon);
    end
    
    %%%%%%%%%%%%%%%% Update Weight Gradient %%%%%%%%%%%%%%%%%%%


    % Update Weights using Perturbation-based Gradient
    layer2 = layer2 - learning_rate * gradient_layer2;
    layer1 = layer1 - learning_rate * gradient_layer1;

    % Increment the sample count
    sample_count = sample_count + 1;

    %%%%%%%%%%%%%%% Calculate Accuracy %%%%%%%%%%%%%%%

    % Calculate and store accuracy every 10,000 images
    if mod(sample_count, batch_size) == 0

        % Calculate accuracy for the current batch
        num_correct = 0;
        for k = (sample_count - batch_size + 1):sample_count
            % Forward Propagation
            output_L1 = [number(:, k)' 1] * layer1;
            activity_L1 = 1 ./ (1 + exp(-output_L1));
            output_L2 = [activity_L1 1] * layer2;
            f_pred = 1 ./ (1 + exp(-output_L2));

            [~, predicted_label] = max(f_pred);  % Get predicted label
            if predicted_label - 1 == label(k)  % Compare with true label
                num_correct = num_correct + 1;
            end
        end
        
        accuracy = (num_correct / batch_size) * 100;  % Calculate accuracy percentage
        accuracy_history(sample_count / batch_size) = accuracy;  % Store accuracy
        fprintf('Accuracy after %d images: %.2f%%\n', sample_count, accuracy);
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

