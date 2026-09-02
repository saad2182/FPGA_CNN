clear all;
close all;
clc;

script_dir = fileparts(mfilename('fullpath'));
repo_root = fileparts(script_dir);
image_dir = fullfile(repo_root, 'data', 'images');
memory_dir = fullfile(repo_root, 'data', 'memory');

tic
stride =1; padding =0 ;
resizeFactor=.1;

%%
%Preparing filter block
Filter_raw=imresize (imread(fullfile(image_dir, 'pattern.jpg')),resizeFactor);
figure;
imshow(Filter_raw);
bw_pattern_image=(rgb2gray(Filter_raw));% converting the image into gray
figure();
imshow(bw_pattern_image);
reduced_pattern=double(bw_pattern_image/32-1);
pattern_hex=dec2hex(reduced_pattern(:));
dlmwrite (fullfile(memory_dir, 'pattern_hex.txt'),pattern_hex,'Delimiter','');
%making 3D filter for 3D input (rgb)
filter(:,:,1) = [-1 -2 -1; 0 0 0;1 2 1]; % this is 1D filter
filter_horizontal(:,:,1)=[-1 0 1;-2 0 2;-1 0 1];% Sobel Horizontal Filter
filter_laplasian(:,:,1)=[0 -1 0;-1 4 -1;0 -1 0];% Laplasian Filter

%%

%Preparing Input image block
Image_raw = imresize (imread(fullfile(image_dir, 'sample-3.jpg')),resizeFactor);
figure;
imshow(Image_raw);
bw_image_input=(rgb2gray(Image_raw));% converting the image into gray
figure();
imshow(bw_image_input);
reduced_sample=uint8(bw_image_input/32-1);
sample_hex=dec2hex(reduced_sample(:));
dlmwrite (fullfile(memory_dir, 'sample_hex.txt'),sample_hex,'Delimiter','');

%%
%Convolution Between FFilter and Image_processed
pattern_image_convoluted=ConvLayer(bw_pattern_image,filter,padding,stride);
figure();
imshow(pattern_image_convoluted);
input_image_convoluted=ConvLayer(bw_image_input,filter,padding,stride);
figure();
imshow(input_image_convoluted);
final_image=ConvLayer(input_image_convoluted,pattern_image_convoluted,padding,stride);
figure();
imshow(final_image);

%%
%MaxPooling layer cascaded with the Convolution.
maxpooled_image=MaxPoolLayer(final_image,padding,2);
figure();
surf(maxpooled_image);%3D view of the maxpooled values

%%
% determining how many pattern detected
max_image_value=max(max(maxpooled_image));% finding the maximum value
norm_image=(maxpooled_image./max_image_value);%normailzing the values of maxpooled image
[row,column]=size(norm_image);
output=zeros(size(norm_image));

for i=1:row
    for j=1:column
        if norm_image(i,j)>0.85 % Threshold for spike
            output(i-2:i,j-2:j)=0; % Putting pixel values as black
        else
            output(i,j)=1; % Putting pixel values as white
        end
    end
end
figure();
imshow(output);
toc
