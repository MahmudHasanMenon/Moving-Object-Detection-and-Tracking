
clc
clear all
close all

% image directory and extension

imPath = 'highway';
imExt = 'jpg';

 
inputImages = 'Frames';

% check if directory and files exist
if isdir(fullfile(imPath, inputImages)) == 0
    error('USER ERROR : The image directory does not exist');
end

 

% Loading Original Video Sequence

filearray = dir([imPath filesep inputImages filesep '*.' imExt]); % get all files in the directory
NumImages = size(filearray,1); % get the number of images
if NumImages < 0
    error('No image in the directory');
end

disp('Loading input image files......');
imgname = [imPath filesep inputImages filesep filearray(1).name]; % get image name
I = imread(imgname);
VIDEO_WIDTH = size(I,2);
VIDEO_HEIGHT = size(I,1);

ImSeq = zeros(VIDEO_HEIGHT, VIDEO_WIDTH, NumImages);
for ii = 1 : NumImages
    imgname = [imPath filesep inputImages filesep filearray(ii).name]; % get image name
    ImSeq(:, :, ii) = rgb2gray(imread(imgname)); % load image
end

 

disp(' OK!');

N=1;
threshold = 40;
alpha = 0.1;
I = ImSeq(:,:,1:20);
figure('name', 'Background Subtraction', 'units', 'normalized', 'outerposition', [0 0.2 1 0.6]);
%we have to use 470 images for background model
tic;

Background = median(I, 3);

toc;

Total_Precision=0;
Total_Recall=0;
Total_F=0;




%and then use image 471 to 1700 to detect the car on the highway
for i=N+1:8
    tic;
    Current_Image = ImSeq(:,:,i);
    Difference    = abs(Current_Image - Background);
 
    Object = Difference > threshold;
    figure(1), subplot(1,3,2), imshow(Object,[]); title('Detected Object');  
     
    Object_new = bwareaopen(Object, 30);
     
    
    Object_new = imfill(Object_new, 'holes'); 
    Object_new = bwmorph(Object_new, 'bridge', 'Inf');
    Object_new = imfill(Object_new, 'holes');
    Object_new = bwmorph(Object_new, 'erode', 1);
    Object_new = bwmorph(Object_new, 'dilate', 1);
    Object_new = medfilt2(Object_new, [5 5]);
    Object_new = bwmorph(Object_new, 'dilate', 1);
    Object_new = bwmorph(Object_new, 'bridge', 'Inf');
    Object_new = imfill(Object_new, 'holes');
        
   % stats = regionprops(bwlabel(Object), 'Centroid', 'BoundingBox', 'Area');
    

   % figure(1), subplot(1,3,2), imshow(Current_Image, []); title('Tracked Object');
   % [row, col] = size(stats);
     
    figure(1), subplot(1,3,1), imshow(Current_Image, []); title('Current Image');
    figure(1), subplot(1,3,3), imshow(Object_new, []); title('After Noise Removal');
    %figure(1), subplot(2,2,4), imshow(Object_new, []);
    drawnow;
    
end


 
