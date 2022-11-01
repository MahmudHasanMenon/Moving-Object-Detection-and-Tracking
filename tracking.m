
clc
clear all
close all

% image directory and extension

imPath = 'highway';
imExt = 'jpg';

groundTruthImages = 'groundtruth';
inputImages = 'input';

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

% Groundtruth Video Sequence Loading
disp('Loading ground truth image......');
imExt = 'png';
filearray = dir([imPath filesep groundTruthImages filesep '*.' imExt]);
imgname = [imPath filesep groundTruthImages filesep filearray(1).name]; % get image name
ImSeq_GroundTruth = zeros(VIDEO_HEIGHT, VIDEO_WIDTH, NumImages);
for ii = 1 : NumImages
    imgname = [imPath filesep groundTruthImages filesep filearray(ii).name]; % get image name
    ImSeq_GroundTruth(:, :, ii) = imread(imgname); % load image
end
 
disp(' OK!');

N=1000;
threshold = 40;
alpha = 0.1;
I = ImSeq(:,:,1:400);
figure('name', 'Background Subtraction', 'units', 'normalized', 'outerposition', [0 0.2 1 0.6]);
%we have to use 470 images for background model
tic;

Background = median(I, 3);
toc;

Total_Precision=0;
Total_Recall=0;
Total_F=0;




%and then use image 1000 to 1700 to detect the car on the highway
for i=N+1:NumImages
    tic;
    Current_Image = ImSeq(:,:,i);
    Difference    = abs(Current_Image - Background);
 
    Object = Difference > threshold;
    %figure(1), subplot(1,3,3), imshow(Object, []); title('Detected Object'); 
    Object_new = bwareaopen(Object, 30);
     %figure(1), subplot(1,3,3), imshow(Object_new, []); title('Detected Object'); 
    
    %figure(1), subplot(1,3,3), imshow(Object_new, []); title('Detected Object');
    Object_new = imfill(Object_new, 'holes'); 
    Object_new = bwmorph(Object_new, 'bridge', 'Inf');
    Object_new = imfill(Object_new, 'holes');
    Object_new = bwmorph(Object_new, 'erode', 1);
    Object_new = bwmorph(Object_new, 'dilate', 1);
    Object_new = medfilt2(Object_new, [5 5]);
     figure(1), subplot(1,3,3), imshow(Object_new, []); title('Detected Object'); 
    Object_new = bwmorph(Object_new, 'dilate', 1);
    Object_new = bwmorph(Object_new, 'bridge', 'Inf');
    Object_new = imfill(Object_new, 'holes');
        
    stats = regionprops(bwlabel(Object), 'Centroid', 'BoundingBox', 'Area');
    

   figure(1), subplot(2,2,4), imshow(Current_Image, []); title('Tracked Object');
     [row, col] = size(stats);
    for j=1:row
        if(stats(j).Area>100)
           rectangle('Position', stats(j).BoundingBox, 'EdgeColor','r');

            hold on;
           plot(stats(j).Centroid(1), stats(j).Centroid(2), '.', 'Color', 'r', 'MarkerSize',10);
            hold off;
        end
    end
    
    figure(1), subplot(2,2,1), imshow(Current_Image, []); title('Current Image');
   figure(1), subplot(2,2,2), imshow(Object, []); title('Detected Object');
   figure(1), subplot(2,2,3), imshow(Object_new, []);title('After Noise Removal');
    drawnow;
    
     Object_GroundTruth = uint8(im2bw(ImSeq_GroundTruth(:, :, i)));
    Object_GroundTruth(Object_GroundTruth == 1) = 2; 
    
    ScoreFrame = Object_GroundTruth + uint8(Object_new);
    
    True_Negative = size(find(ScoreFrame == 0), 1);
    False_Positive = size(find(ScoreFrame == 1), 1);
    False_Negative = size(find(ScoreFrame == 2), 1);
    True_Positive = size(find(ScoreFrame == 3), 1);
    
    Current_Precision = (True_Positive / (True_Positive + False_Positive));
       
    Total_Precision = Total_Precision + Current_Precision;
   %  x(i)=Total_Precision;
    Current_Recall = (True_Positive / (True_Positive + False_Negative));
       
 
    
    Total_Recall = Total_Recall + Current_Recall;
     %y(i)=Total_Recall;
    Current_F = (2 * ((Current_Precision * Current_Recall) / (Current_Precision + Current_Recall)));
    Total_F = Total_F + Current_F;

    
    
toc;
end


display(strcat('Average Precision : ', num2str(Total_Precision/(NumImages-(N+1)))));
display(strcat('Average Recall : ', num2str(Total_Recall/(NumImages-(N+1)))));
display(strcat('Average F-Score : ', num2str(Total_F/(NumImages-(N+1)))));

