 close all
 clear
clc


%% read

images = {'image_hc_104.jpg','image_hc_30.jpg','image_hc_17.jpg','image_hc_7.jpg'};

pathimg='D:\simhawk\Task2-20231012T072306Z-001\Task2';
flag=false;
for ind=1:length(images)
    img = imread(fullfile(pathimg,images{ind}));
     [mmperimeter] = getPerimeter(img,flag);
end