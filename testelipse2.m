clear all
close all
addpath('D:\code2018\ellipseDetection')
addpath('D:\code2018\frangi_filter_version2a')

%% detect 2 ellipses
img = imread('ellipse3.jpg');
img=rgb2gray(img);

figure
imagesc(img);
colormap('gray');

%% frangi
Ivessel=FrangiFilter2D(double(img));
figure
subplot(1,2,1), imshow(img,[]);
subplot(1,2,2), imshow(Ivessel,[0 0.25]);title('frangi')

%% detect ellipse
maxIv = max(Ivessel(:));

figure()
hist(Ivessel(:),128);title('histogram filtered image')
set(gca,'yscale','log')

% threshold change by experience can be determined by all cases learning 
% or by search on histogram levels
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

plot_ellipse(detected_ellipses,img)

%% use hough
% at canny we have to much edges and frangi
% is better to find long object
E = LogicVessel; %edge(denoisedImage,'canny');
figure(), imshow(E);title('edge frangi')

% override some default parameters
params.minMajorAxis = 50;
params.maxMajorAxis = 500;

% note that the edge (or gradient) image is used
% [x0 y0 a b alpha score] 
bestFits = ellipseDetection(E, params);

fprintf('Output %d best fits.\n', size(bestFits,1));

figure;
image(img);

ellipse(bestFits(:,3),bestFits(:,4),bestFits(:,5)*pi/180,bestFits(:,1),bestFits(:,2),'R');
title('allfits')

[mx idx] = sort(bestFits(:,6),'descend');
figure;
image(img);
ellipse(bestFits(idx(1:2),3),bestFits(idx(1:2),4),bestFits(idx(1:2),5)*pi/180,bestFits(idx(1:2),1),bestFits(idx(1:2),2),'R');
 title('best fit hough')% still dint find the best 

%% binary work

BW = ~(img>100);
BW = bwareaopen(BW,10);
figure,imshow(BW);title('binary thresholded')

CC = bwconncomp(BW);

% Create a label matrix
label_matrix = labelmatrix(CC);
% Use label2rgb to assign different colors to labels
colored_labels = label2rgb(label_matrix, 'hsv', 'k', 'shuffle');
% Display the colored connected components
figure()
imshow(colored_labels);
title('Colored Connected Components');


 %% morphology
 SE = strel("square",3)
  bw=imopen(LogicVessel,SE);
 figure,imshow(bw)

 idx = find(bw);
 [jj,ii]=ind2sub(size(bw),idx);

  figure,imshow(bw),hold on,plot(ii,jj,'c.')


 X = [ii jj];
 idx = kmeans(X,2);

 figure,imshow(bw)
 hold on
 plot(X(idx==1,1),X(idx==1,2),'r.')
 plot(X(idx==2,1),X(idx==2,2),'b.')
 title('kmeans clustering')

 [Xout,idxOut ]= clearClusters(X,idx,bw);

  figure,imshow(bw)
 hold on
 plot(Xout(idxOut==1,1),Xout(idxOut==1,2),'r.')
 plot(Xout(idxOut==2,1),Xout(idxOut==2,2),'b.')
 title('kmeans clustering clean intenal cluster')


 % detect elipse
detected_ellipses1 = fit_ellipse(Xout(idxOut==1,1),Xout(idxOut==1,2));
detected_ellipses2 = fit_ellipse(Xout(idxOut==2,1),Xout(idxOut==2,2));

disp(detected_ellipses1)
disp(detected_ellipses2)

plot_ellipse(detected_ellipses1,img)
plot_ellipse(detected_ellipses2,img)


;

