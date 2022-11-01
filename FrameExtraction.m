clc
clear all
close all

% image directory and extension

imPath = 'highway';
imExt = 'jpg';

inputImages = 'Frames';

% check if directory and files exist


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

N=400;
threshold = 40;
alpha = 0.1;
I = ImSeq(:,:,1:444);
figure('name', 'Background Subtraction', 'units', 'normalized', 'outerposition', [0 0.2 1 0.6]);
%we have to use 470 images for background model
tic;

Background = median(I, 3);
toc;

tic;
%and then use image 471 to 1700 to detect the car on the highway
for i=N+1:NumImages
    Current_Image = ImSeq(:,:,i);
   
    Difference    = abs(Current_Image - Background);
  imshow(Difference>threshold);
    drawnow;
  
        end

toc;

