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
   
            %%%%%%%%%%%%%% Forward Propagation %%%%%%%%%%%%%%%%%%%%%%
            s1=number(:,1)';
            output_L1=[s1 1]*layer1;
            activity_L1=1./(1+exp(-output_L1));
            derivative_L1=exp(-output_L1)./(1+exp(-output_L1)).^2; % 1st derivative of the activity function
            
            output_L2=[activity_L1 1]*layer2;
            f=1./(1+exp(-output_L2));
            derivative_L2=exp(-output_L2)./(1+exp(-output_L2)).^2; % 1st derivative of the activity function            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
            %%%%%%%%%%%%%% Backward Propagation 1 %%%%%%%%%%%%%%%%%%%  
            labelvector=zeros(1,10);        
            labelvector(label(i)+1)=1;           % This is the target label value
            dEdf=(f-labelvector).*derivative_L2; % 1st derivative of the activity function: element-wise multiplications
    
            BackOutput_L2=dEdf*layer2';
            BackOutput_L2=[derivative_L1 1].*BackOutput_L2; % 1st derivative of the activity function: element-wise multiplications
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
            %%%%%%%%%%%%%%%%%%%%% Two vectors %%%%%%%%%%%%%%%%%%%%%%    
            rho_forward=[s1 1 activity_L1 1 f]'; % activities through forward pass
            delta_backward=[zeros(1,NumInput+1) BackOutput_L2 dEdf]'; % activities through backward pass
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        
            %%%%%%%%%%%%%%%%%%%%%% Gradients %%%%%%%%%%%%%%%%%%%%%%%%
            gradientt=rho_forward*delta_backward'; % outer product of two vectors
            gradient=gradientt.*gradientMatrix_dummy; % upper triangle just for visualization
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%%%%%%%%%%%%%%%%%%%%% Graphs %%%%%%%%%%%%%%%%%%%%%%%%%%
            
            figure;
            subplot(1,2,1);
            imagesc(transpose(reshape(number(:,i)',[8,8])));
            axis('square');
            
            subplot(1,2,2);
            imagesc(gradient,[-1e-3, 1e-3]);
            axis('square');            
end