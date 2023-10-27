function [mmperimeter] = getPerimeter(img,flag)
%getPerimeter Summary of this function goes here
%   Detailed explanation goes here

%% read
% img=imread('D:\simhawk\Task2-20231012T072306Z-001\Task2\image_hc_104.jpg');148 vs186 gt
% img=imread('D:\simhawk\Task2-20231012T072306Z-001\Task2\image_hc_30.jpg');%211 Gt vs me 166

%img=imread("D:\simhawk\Task2-20231012T072306Z-001\Task2\image_hc_17.jpg");
%img = imread("D:\simhawk\Task2-20231012T072306Z-001\Task2\image_hc_7.jpg");

img=rgb2gray(img);
img= imadjust(img);

if(flag)
figure,imshow(img)
title('adjusted gray')
end

%% blur

% Define the standard deviation (sigma) for Gaussian blur
sigma = 5;  % You can adjust this value as needed

% Apply Gaussian blur to the image
blurred_image = imgaussfilt(img, sigma);
if(flag)
figure,imshow(blurred_image)
title('blurred')
end

%% threshold

%level = graythresh(blurred_image);
%Create a binary image using the computed threshold and display the image.

%BW = imbinarize(blurred_image,level);
BW = blurred_image>150;
if(flag)
figure
imshow(BW),title('bw')
end

% Overlay the binary mask on the grayscale image
maskedImage = imoverlay(img, BW, [1 0 0]); % Red color for overlay

% Display the masked image
if(flag)
figure;
imshow(maskedImage);
title('Grayscale Image with Binary Mask Overlay');
end
%% ---
%{
  se = strel("rectangle",[19 3]) ;
  erodedBW = imerode(BW, se);
  figure
  imshow(erodedBW);title('erodedBW')

   se = strel("line",30,0);
   imLine0= imopen(erodedBW, se);
     figure
  imshow(imLine0);title('imLine0')
%}

%% dilate
  se = strel("rectangle",[3 5]) ;
  dilatedBW = imdilate(BW, se);

    if(flag)
  figure
  imshow(dilatedBW);title('dilatedBW')
    end

  BW_outE = bwpropfilt(dilatedBW,'EulerNumber',[-4, 1]);
  if(flag)
    figure
  imshow(BW_outE);title('BW_outE')
  end
  %% close angles
  ncl=30;
se = strel("line",ncl,45);
im45= imclose(BW_outE, se);

if(flag)
imshow(im45);title('im45')
plotblob(im45);
plotMasked(img,im45)
end

se = strel("line",ncl,135);
im135= imclose(im45, se);

if(flag)
imshow(im135);title('im135')
plotblob(im135);
plotMasked(img,im135)
end

  %% clean binary
  [BW_outA,propertiesA] = filterRegionsXX(im135);

  if(flag)
   figure
  imshow(BW_outA);title('BW_outA')
plotblob(BW_outA);

plotMasked(img,BW_outA)
  end

%% filter upper part us if seperated 
%top left width height
stats = regionprops(BW_outA,"BoundingBox","Circularity","Eccentricity");

exclude=[];
for(k=1:length(stats))
   topleftY=stats(k).BoundingBox(2);
   yDown = topleftY+stats(k).BoundingBox(4);

   if(topleftY<150 && yDown<260)
       exclude=[exclude, yDown];
   end

end


if(length(exclude)>0)
    nm=int16(max(exclude));
    BW_outA(1:nm,:)=0;
end

% plotMasked(img,BW_outA)

%% close 90deg
 se = strel("line",300,90);%200
 im90= imclose(BW_outA, se);
 if(flag)
 figure
imshow(im90);title('im90')
plotblob(im90);
plotMasked(img,im90)
 end

%{
    % Compute the skeleton
skeleton = bwmorph(im90, 'skel', Inf);

% Display the skeleton
imshow(skeleton);

% Find branch endpoints
endpoints = bwmorph(skeleton, 'endpoints');

% Compute branch lengths
skeleton_dist = bwdistgeodesic(skeleton, endpoints);

% Find the longest branch
[max_length, branch_idx] = max(skeleton_dist(:));
[branch_row, branch_col] = ind2sub(size(skeleton_dist), branch_idx);

% Create a mask for the longest branch
longest_branch_mask = zeros(size(skeleton));
longest_branch_mask(branch_row, branch_col) = 1;

% Remove all branches except the longest one
pruned_skeleton = skeleton & longest_branch_mask;

% Display the pruned skeleton
imshow(pruned_skeleton);

%}

%% old
%{
 [BW_outA,propertiesA] = filterRegionsUSA(erodedBW);%BW);
 figure
 imshow(BW_outA);title('cleaned by area')

 maskedImage = imoverlay(img, BW_outA, [1 0 0]); % Red color for overlay

% Display the masked image
figure;
imshow(maskedImage);
title('Grayscale Image with Binary Mask Overlay');


  se = strel("rectangle",[5 7]) ;
  erodedBW = imerode(BW_outA, se);
  figure
  imshow(erodedBW);title('erodedBW')

  se = strel("rectangle",[3 5]) ;
  dilatedBW = imdilate(erodedBW, se);
  figure
  imshow(dilatedBW);title('dilatedBW')

   %plotblob(dilatedBW);

   dilatedBWC  = filterRegionsC(dilatedBW);

        figure
  imshow(dilatedBWC);title('dilatedBWC')
plotblob(dilatedBWC);

    se = strel("line",30,45);
    im45= imclose(dilatedBWC, se);
    se = strel("line",30,135);
    im135= imclose(im45, se);

         figure
  imshow(im135);title('im135')
plotblob(im135);

      im135_out = bwpropfilt(im135,'Perimeter',[600, 2200]);%1796,euler 800, 2000
im135_out = bwpropfilt(im135_out,'EulerNumber',[-10, 1]);

        figure
  imshow(im135_out);title('im135b')
plotblob(im135_out);

        se = strel("line",300,90);%200
         im90= imclose(im135_out, se);

   

    figure
  imshow(im90);title('im90')
plotblob(im90);
%}

   %% ellipse
   cc = bwconncomp(im90);%)im90);

   props = regionprops(cc, 'Centroid', 'PixelList');
  detected_ellipses = cell(1, cc.NumObjects);

for k = 1:cc.NumObjects
    % Extract the pixel coordinates of the connected component
    pixels = props(k).PixelList;
    
    % Fit an ellipse to the connected component
    detected_ellipses{k} = fit_ellipse(pixels(:, 1), pixels(:, 2));
end


figure;
imshow(img);
%imshow(im90)%BW)
hold on;

for k = 1:cc.NumObjects
    ellipse = detected_ellipses{k};

       % Extract ellipse properties
    a = ellipse.a;
    b = ellipse.b;

    if(isempty(a))
        continue
    end

    perimeter = 2 * pi * sqrt((a^2 + b^2) / 2);

    phi = ellipse.phi;
    X0_in = ellipse.X0_in;
    Y0_in = ellipse.Y0_in;
    long_axis = ellipse.long_axis;
    short_axis = ellipse.short_axis;
    
    % Calculate the coordinates of the points on the ellipse
    t = linspace(0, 2 * pi, 100);  % Adjust the number of points as needed
    x = a * cos(t);
    y = b * sin(t);
    
    % Rotate the ellipse to the correct orientation
    R = [cos(phi) -sin(phi); sin(phi) cos(phi)];
    rotated_points = R * [x; y];
    
    % Translate the rotated ellipse to its center
    x_rotated = rotated_points(1, :) + X0_in;
    y_rotated = rotated_points(2, :) + Y0_in;
    
    % Plot the ellipse on the image
    plot(x_rotated, y_rotated, 'g', 'LineWidth', 2);

    %plot(ellipse(:, 1), ellipse(:, 2), 'g', 'LineWidth', 2);
end

hold off;
title(['Fitted Ellipses on Binary Image - Perimeter: ' num2str(perimeter)]);


dpi=144;
tomm=25.4;
scale=1/2;
mmperimeter = scale*tomm*perimeter/dpi;
title(['Fitted Ellipses on Binary Image - Perimeter: ' num2str(mmperimeter)]);



end