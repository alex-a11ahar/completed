%%UIN:928009686

% Load plaintext, ciphertext, traces, and sbox
load 'aes_power_data.mat';  
bytes_recovered = zeros (1,16);
n_traces = 200; 

traces = traces (1:n_traces, :); 

%% Launch DPA and compute DoM , size of DoM 256 x 40000
%part 1 (Launch DPA)

byte_to_attack=16
key_guess = uint8([0:255]) %1*256

y = zeros(n_traces, 256);  % Initialize the predicted Sbox output matrix

input_plaintext = plain_text(:,byte_to_attack)

for i = 1:200
 y(i,:)=sbox(bitxor(key_guess,input_plaintext(i))+1)
end

power_consumption = bitget(y,1); % LSB (index = 1)

% part 2 (DoM)

% Initialize power trace classification matrix for LSB
group_0_sum = zeros(1, size(traces, 2));  
group_1_sum = zeros(1, size(traces, 2)); 
count_0 = 0;  % Group 0 trace counter
count_1 = 0;  % Group 1 trace counter

% Initialize DoM 256 x 40000
DoM = zeros(256, size(traces, 2));  

% Loop through each key guess and classify power traces

for col = 1:256
    for trace_idx = 1:n_traces
        if power_consumption(trace_idx, col) == 1
            group_1_sum = group_1_sum + traces(trace_idx, :); 
            count_1 = count_1 + 1;
        else
            group_0_sum = group_0_sum + traces(trace_idx, :);
            count_0 = count_0 + 1;
        end
    end
    
% compute DoM

    if count_0 > 0 && count_1 > 0
        mean_0 = group_0_sum / count_0;  
        mean_1 = group_1_sum / count_1;  
        DoM(col, :) = mean_1 - mean_0;  %DoM power trace for this key guess
    end
    
% Reset power trace classification matrix for LSB next key guess
    group_0_sum = zeros(1, size(traces, 2));
    group_1_sum = zeros(1, size(traces, 2));
    count_0 = 0;
    count_1 = 0;
end


% max DoM trace value = correct key guess (top 16)
max_DoM_values = max(abs(DoM), [], 2);  % Find the maximum value in DoM matrix (top 16)

[~, sorted_indices] = sort(max_DoM_values, 'descend');  % Sort key guesses by DoM value in descending order
top_16_indices = sorted_indices(1:16);  % Select the top 16 key guesses

% Plot the Top 16 Key Guesses

figure;
N = 4;  % Number of rows and columns for the subplot (4x4 grid)
for i = 1:N
    for j = 1:N
        index = (i-1)*N + j;  % Calculate the index for each subplot
        if index <= 16
            subplot(N, N, index);
            plot(DoM(top_16_indices(index), :));  % Plot the DoM trace for the top key guess
            title(['Key Guess: ', num2str(top_16_indices(index))]);
        end
    end
end
