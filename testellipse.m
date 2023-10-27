close all
clear all

addpath('D:\code2018\ellipseDetection')
addpath('D:\code2018\frangi_filter_version2a')

%% read
img= imread('ellipse4.JPG');
img=rgb2gray(img);
%add noise

imgNoised = imnoise(img,'salt & pepper', 0.02);

figure
imshow(imgNoised);title('org image +SaltPepper')

%filter
img = medfilt2(imgNoised);
figure
imshow(img);title('filtered median')

%% frangi

Ivessel=FrangiFilter2D(double(img));
figure
subplot(1,2,1), imshow(img,[]);
subplot(1,2,2), imshow(Ivessel,[0 0.25]);title('frangi filtered')

%% detect ellipse
maxIv = max(Ivessel(:));
LogicVessel = Ivessel>0.9*maxIv;
figure
imshow(LogicVessel);title('LogicVessel')

% detect positive pixels
ind = find(LogicVessel);
[jj,ii] =  ind2sub(size(LogicVessel),ind);

figure()
imshow(LogicVessel);title('LogicVessel and pixels')
hold on;
plot(ii,jj,'r.')

figure()
imshow(img);title('img and pixels')
hold on;
plot(ii,jj,'r.')

detected_ellipses = fit_ellipse(ii ,jj);

disp(detected_ellipses)
plot_ellipse(detected_ellipses,imgNoised);

%% method Hough
E = edge(img,'canny');
figure(), imshow(E);title('edge canny')

% override some default parameters
params.minMajorAxis = 50;
params.maxMajorAxis = 300;

% note that the edge (or gradient) image is used
% [x0 y0 a b alpha score] 
bestFits = ellipseDetection(E, params);

fprintf('Output %d best fits.\n', size(bestFits,1));

figure;
image(img);

ellipse(bestFits(:,3),bestFits(:,4),bestFits(:,5)*pi/180,bestFits(:,1),bestFits(:,2),'R');
title('allfits')

[mx idx] = max(bestFits(:,6));
figure;
image(img);
ellipse(bestFits(idx,3),bestFits(idx,4),bestFits(idx,5)*pi/180,bestFits(idx,1),bestFits(idx,2),'R');
 title(['best fit hough', num2str(bestFits(idx,3)), ' ', num2str(bestFits(idx,4)) ])


