% The function Layer acts as a kernel that can do convolution 
% This function can handle input of any dimension; the filter must be in the same dimension
% if input is 3D, filter has to be 3D 
% written by Tahmid Abtahi,UMBC;for questions: abtahi1@umbc.edu; 

function output =    ConvLayer(input,filter,padding,stride)

input= double(input);
input= padarray(input, [padding padding]); % zero_padding
[inputLength inputHeight dimI ] = size(input);
[filterLength filterHeight dimF]=size(filter);

for k=1:dimI;

    i =1;j=1;
    for y =1 : stride : (inputHeight- filterHeight+1) %filter window movement on y axis
        for x=1: stride :(inputLength - filterLength+1) %filter window movement on x axis

            patch = input(x:x+filterLength-1,y:y+filterHeight-1,k);

       
                out =  dot_sum(double(patch),double(filter(:,:,k)));  %for convolution

% 
%             if (type ==2)
%                 out = max(max(patch)); %max pool
%             end
%             
%             if (type ==3)
%                 out = avg(avg(patch)); %max pool
%             end

            result(i,j) = out;
            i=i+1;
        end
        j=j+1;i=1;
    end
    %%

    output_temp(:,:,k) = result; 
 
end
    output = zeros(size(output_temp(:,:,1)));
 
    for i=1:k
        output = output + output_temp(:,:,i);
    end
 

end