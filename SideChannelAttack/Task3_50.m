%UIN: 928009686
% Load plaintext, ciphertext, traces, and sbox
load 'aes_power_data.mat';  
bytes_recovered = zeros (1,16);
n_traces = 50; 

traces = traces (1:n_traces, :); 

%% Launch DPA and compute DoM , size of DoM 256 x 40000
%part 1 (Launch DPA)
for byte_to_attack= 1:16
    key_guess = uint8([0:255]) %1*256
    
    y = zeros(n_traces, 256);  % Initialize the predicted Sbox output matrix
    
    input_plaintext = plain_text(:,byte_to_attack)
    
    for i = 1:50
        y(i,:)=sbox(bitxor(key_guess,input_plaintext(i))+1)
    end
    
    power_consumption = bitget(y,1); % LSB (index = 1)

% part 2 (DoM)

    % Initialize DoM 256 x 40000
    DoM = zeros(256, size(traces, 2));  
    
    % Loop through each key guess and classify power traces
    
    for col = 1:256
    % Initialize power trace classification matrix for LSB
    group_0_sum = zeros(1, size(traces, 2));  
    group_1_sum = zeros(1, size(traces, 2)); 
    count_0 = 0;  % Group 0 trace counter
    count_1 = 0;  % Group 1 trace counter
    
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
        else
            DoM(col, :) = zeros(1, size(traces, 2));  % Set DoM to zero if one group is empty
        end
    end

% Find the absolute maximum value in the DoM trace
    [~, idx] = max(abs(DoM(:)));  % Get the linear index of the maximum absolute value
    [key_guess_idx, ~] = ind2sub(size(DoM), idx);  % Get the key guess associated with the max value

% Store the key guess for this byte
    bytes_recovered(byte_to_attack) = key_guess_idx - 1;  % Store the key guess (0-based index)
end
    
%compare with the golden key :

% golden key = key_guess 256
golden_key = [199, 18, 213, 149, 19, 108, 191, 234, 181, 164, 16, 248, 213, 96, 90, 22];

% Compare the recovered key with the golden key
if isequal(bytes_recovered, golden_key)
    disp('The recovered key matches the golden key.');
else
    disp('The recovered key does not match the golden key.');
end

% Bitwise accuracy comparison
recovered_key_bin = reshape(dec2bin(bytes_recovered, 8)', 1, []);  % Convert recovered key to binary string
golden_key_bin = reshape(dec2bin(golden_key, 8)', 1, []);          % Convert golden key to binary string

% Calculate bitwise accuracy
bit_matches = sum(recovered_key_bin == golden_key_bin);
accuracy_percentage = (bit_matches / 128) * 100;  % 128 bits (16 bytes * 8 bits per byte)

% Display the Recovered Key
disp('Recovered AES Key (in hexadecimal):');
disp(dec2hex(bytes_recovered));  % Display the recovered key as a 16x1 vector in hexadecimal

% Display the bitwise accuracy
fprintf('Bitwise Accuracy: %.2f%%\n', accuracy_percentage);