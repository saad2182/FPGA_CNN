% The function Layer acts as a kernel that can do Maxpooling  
% for questions by Tahmid Abtahi,UMBC;abtahi1@umbc.edu; 

function output =    MaxPoolLayer(input,padding,factor)

input= double(input);
input= padarray(input, [padding padding]); % zero_padding
[inputLength inputHeight dimI ] = size(input);
filterHeight = factor;
filterLength = factor;
stride=factor;

for k=1:dimI;

    i =1;j=1;
    for y =1 : stride : (inputHeight- filterHeight+1) %filter window movement on y axis
        for x=1: stride :(inputLength - filterLength+1) %filter window movement on x axis

            patch = input(x:x+filterLength-1,y:y+filterHeight-1,k);

       
            out = max(max(patch)); %max pool


            result(i,j) = out;
            i=i+1;
        end
        j=j+1;i=1;
    end
    %%

    output(:,:,k) = result; 
 
end
 
end