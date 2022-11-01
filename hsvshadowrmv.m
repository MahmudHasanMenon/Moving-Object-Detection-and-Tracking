function shadowremoval()
obj = setupSystemObjects();
while ~isDone(obj.reader)
    frame = readFrame();
    mask1 = shadow(frame);
    displayTrackingResults();
end
%% Create System Objects
      function obj = setupSystemObjects()
          % Create a video file reader.
          obj.reader = vision.VideoFileReader('car.mp4');
          % Create two video players, one to display the video,
          % and one to display the foreground mask.
          obj.videoPlayer = vision.VideoPlayer('Position', [10, 250, 700, 400]);
          obj.maskPlayer = vision.VideoPlayer('Position', [720, 250, 700, 400]);
          obj.detector = vision.ForegroundDetector('NumGaussians', 3, ...
              'NumTrainingFrames', 40, 'MinimumBackgroundRatio', 0.7);
      end
  %% Read a Video Frame
  % Read the next video frame from the video file.
      function frame = readFrame()
          frame = obj.reader.step();
      end
  %% Perform the operation to remove shadows 
      function mask1 = shadow(frame)
  Background=0.0;
          % Detect foreground.
          mask1 = obj.detector.step(frame);
          mask1 = uint8(repmat(mask1, [1, 1, 3])) .* 255;
          % Apply morphological operations to remove noise and fill in holes.
  %         mask1 = imerode(mask1, strel('rectangle', [3,3]));
  %         mask1 = imclose(mask1, strel('rectangle', [15, 15])); 
          mask1 = imopen(mask1, strel('rectangle', [15,15]));
          mask1 = imfill(mask1, 'holes');
          % Now let's do the differencing
          alpha = 0.5;
          if frame == 1
              Background = frame;
          else
              % Change background slightly at each frame
    %             Background(t+1)=(1-alpha)*I+alpha*Background
              Background = (1-alpha)* frame + alpha * Background;
          end
          % Do color conversion from rgb to hsv
          x=rgb2hsv(mask1);
          y=rgb2hsv(Background);
          % Split the hsv component to h,s,v value
          Hx = x(:,:,1);
          Sx = x(:,:,2);
          Vx = x(:,:,3);
          Hy = y(:,:,1);
          Sy = y(:,:,2);
          Vy = y(:,:,3);
          % Calculate a difference between this frame and the background.
          dh=(abs(double(Hx) - double(Hy)));
          ds1=(abs(double(Sx) - double(Sy)));
          dv1=(abs(double(Vx) - double(Vy)));
          % Perform the 'swt'
          [as,hs,vs,ds] = swt2(ds1,1,'haar');
          [av,hv,vv,dv] = swt2(dv1,1,'haar');
          %Compute the skewness value of 'swt of v'
          sav=skewness(av(:));
          shv=skewness(hv(:));
          svv=skewness(vv(:));
          sdv=skewness(dv(:));
          %Compute the skewness value of 'swt of s'
          sas=skewness(as(:));
          shs=skewness(hs(:));
          svs=skewness(vs(:));
          sds=skewness(ds(:));
          %Perform the thresholding operation
           b=(av>=sav);
          c=(hv>=shv);
          d=(vv>=svv);
          e=(dv>=sdv);
          f=(as>=sas);
          g=(hs>=shs);
          h=(vs>=svs);
          i=(ds>=sds);
          j=(b&f);
          k=(c&g);
          l=(d&h);
          m=(e&i);
          %Perform the inverse 'swt'operation
          recv = iswt2(b,c,d,e,'haar');
          recs= iswt2(j,k,l,m,'haar');
          de_shadow=cat(3,dh,recs,recv);
          mask1=hsv2rgb(de_shadow);
          mask1=rgb2gray(mask1);
      end
  function displayTrackingResults()
          % Convert the frame and the mask to uint8 RGB.
          frame = im2uint8(frame);
          mask1 = uint8(repmat(mask1, [1, 1, 3])) .* 255;
  % Display the mask and the frame.
          obj.maskPlayer.step(mask1);        
          obj.videoPlayer.step(frame);
      end
  end