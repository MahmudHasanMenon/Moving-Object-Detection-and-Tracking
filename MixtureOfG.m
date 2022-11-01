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
fr = ImSeq(:, :, 1);
 fr_size = size(fr);
width = fr_size(2);
 height = fr_size(1);
 K = 3; % Numer of Gaussian distributions - generally 3 to 5
 
 M = 1; % 1 because gray - number of background components

 D = 2.5; % positive deviation threshold
 
 alpha = 0.01; % Learning rate between 0 and 1
 
 thresh = 0.1;
 
 sd_init = 6; % initial standart deviation
 
 w = zeros(height, width, K); % initialize Weights array
 mean = zeros(height, width, K); % pixel means
 sd = zeros(height, width, K); % pixel standart deviations
 u_diff = zeros(height, width, K); % diference of each pixel from mean
 p = alpha / (1 / K); % initial p variable (used to update mean and sd)
 rank = zeros(1, K); % rank of components (w / sd)
 
 foreground = zeros(height, width);
 background = zeros(height, width);

% % Inits
 mean = 255 * rand(height, width, K);
 w = (1 / K) * ones(height, width, K);
 sd = sd_init * ones(height, width, K);
 
 figure('name', 'Mixture of Gaussians', 'units', 'normalized', 'outerposition', [0 0 1 1]);
 
% % Process
for kk = 1 : 470 % NumImages
     
    im = ImSeq(:, :, kk);
     
     u_diff(:, :, :) = abs(repmat(im, [1 1 3]) - double(mean(:, :, :)));
     
    % update gaussian components for each pixel
     for ii = 1 : height
         
        for jj = 1 : width
            
            match = 0;
            
             for nn = 1 : K
                
                 if abs(u_diff(ii, jj, nn)) <= D * sd(ii, jj, nn) % pixel matches gaussian component
                     
                   match = 1; % n.th distribution matched
                    
                    % update weights, mean, sd, p
                   w(ii, jj, nn) = (1 - alpha) * w(ii, jj, nn) + alpha;
                     
                   p = alpha / w(ii, jj, nn);
                    
                     mean(ii, jj, nn) = (1 - p) * mean(ii, jj, nn) + p * double(im(ii, jj));
                     
                     sd(ii, jj, nn) = sqrt((1 - p) * (sd(ii, jj, nn) ^ 2) + p * ((double(im(ii, jj)) - mean(ii, jj, nn))) ^ 2);
                     
                 else
                     
                     w(ii, jj, nn) = (1 - alpha) * w(ii, jj, nn); % weight slighly decreases
                    
                 end
                 
             end
             
             w(ii, jj, :) = w(ii, jj, :) ./ sum(w(ii, jj, :));
             
             background(ii, jj) = 0;
             
          for nn = 1 : K
             
              background(ii, jj) = background(ii, jj) + mean(ii, jj, nn) * w(ii, jj, nn);
               
           end
           background(ii, jj) = background(ii, jj) + sum(mean(ii, jj, :) .* w(ii, jj, :));
          
            % if no components match, create new component
             if (match == 0)
                [min_w, min_w_index] = min(w(ii, jj, :));
                mean(ii, jj, min_w_index) = double(im(ii, jj));
                 sd(ii, jj, min_w_index) = sd_init;
            end
            
            rank = w(ii, jj, :) ./ sd(ii, jj, :); % calculate component rank
            rank_ind = 1:1:K;
            
             % sort rank values
             for k = 2 : K
                 
                 for m = 1 : (k - 1)
                   
                    if (rank(:, :, k) > rank(:, :, m))
                       % swap max values
                       rank_temp = rank(:, :, m);
                         rank(:, :, m) = rank(:, :, k);
                         rank(:, :, k) = rank_temp;
                         
                         % swap max index values
                         rank_ind_temp = rank_ind(m);
                         rank_ind(m) = rank_ind(k);
                         rank_ind(k) = rank_ind_temp;
                         
                     end
                     
                 end
                 
             end

% % % sortrows looks more slower then the for loop above :/
           [rank, rank_ind] = sortrows(squeeze(rank), -1);
           rank_ind = rank_ind';
          
           
%             % calculate foreground
          match = 0;
             
             k = 1;
             
             foreground(ii, jj) = 0;
             
             while (match == 0) && (k <= K)
                 
                 if w(ii, jj, rank_ind(k)) >= thresh
                     
                     if abs(u_diff(ii, jj, rank_ind(k))) <= D * sd(ii, jj, rank_ind(k))
                         
                         foreground(ii, jj) = 0;
                         
                         match = 1;
                         
                     else
                         
                         foreground(ii, jj) = im(ii, jj); 
                         
                     end
                    
                 end
                 
                 k = k + 1;
                 
             end
             
         end
         
     end
     
     
     %subplot(1, 3, 1); imshow(im, []);
    %subplot(1, 3, 2); imshow(uint8(background), []);
     %subplot(1, 3, 3); imshow(uint8(foreground), []);
     
     %drawnow;
     
     foregroundFiltered = bwareaopen(foreground, 50, 8);
     se = strel('disk', 13);
     foregroundFiltered = imdilate(foregroundFiltered, se);
     foregroundFiltered = bwmorph(foregroundFiltered, 'bridge', 'Inf');
     
     %foregroundFiltered = medfilt2(foregroundFiltered, [5 5]);
     
     %foregroundFiltered = imfill(foregroundFiltered, 'holes');
     
     %foregroundFiltered = bwmorph(foregroundFiltered, 'erode', 5);
     
     
     
     
     %foregroundFiltered = bwmorph(foregroundFiltered, 'remove');
%     %foreground = bwmorph(foreground,'skel', Inf);
     
     
     boundingBox  = regionprops(foregroundFiltered, 'BoundingBox');
     
     
     subplot(2, 2, 1); imshow(im, []); title('Raw Image');
     
    if ~isempty(boundingBox)
         for bb = 1 : numel(boundingBox)
             rectangle('Position', boundingBox(bb).BoundingBox, 'EdgeColor','r', 'LineWidth', 2);
         end
     end
     
     subplot(2, 2, 2); imshow(foreground); title('Detected Object');
     subplot(2, 2, 3); imshow(foregroundFiltered); title('Filtered');
     subplot(2, 2, 4); imshow(background, []); title('Background');
     
     drawnow;
    
     display(kk);
 end
