

% Load plaintext, ciphertext, traces, and sbox
load 'aes_power_data.mat';  
bytes_recovered = zeros (1,16);
n_traces = 200; 

traces = traces (1:n_traces, :); 

%% Launch DPA and compute DoM , size of DoM 256 x 40000
 %part 1
byte_to_attack=1
key_guess = uint8([0:255]) %1*256

input_plaintext = plain_text(:,byte_to_attack)

for i = 1:200
 y(i,:)=sbox(bitxor(key_guess,input_plaintext(i))+1)
end

power_consumption = bitget(y,1);
% part 2

for col = 1:256
	selec_col = power_consumption(:,col);
	
end

%%
dec2hex(bytes_recovered) 

%compare with the golden key : 
%% Sampe code to  plots 
OFFSSET= 192 ; % for N=64, 0 , 64. 128, 192
N=8; % for an NxN plot
for i = 1:N
    for j  =1:N
        subplot(N,N,(i-1)*N+j)
        plot(DoM ((i-1)*N+j+OFFSSET, :) )
     
    end
end


