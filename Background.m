
clc
clear all
close all

% image directory and extension

imPath = 'highway';
imExt = 'jpg';

groundTruthImages = 'groundtruth';
inputImages = 'Frames';

% check if directory and files exist
if isdir(fullfile(imPath, inputImages)) == 0
    error('USER ERROR : The image directory does not exist');
end

if isdir(fullfile(imPath, groundTruthImages)) == 0
    error('Directory does not exist');
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

N=111;
threshold = 40;
alpha = 0.1;
I = ImSeq(:,:,1:400);
figure('name', 'Background Subtraction', 'units', 'normalized', 'outerposition', [0 0.2 1 0.6]);
%we have to use 470 images for background model
tic;

Background = median(I, 3);
figure(1), subplot(1,3,1), imshow(Background,[]); title('Background');
toc;

 figure(1), subplot(1,3,2), imshow(Background,[]); title('Background');

