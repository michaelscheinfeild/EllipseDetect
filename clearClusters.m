function [Xout ,idxOut]= clearClusters(X,idx,bw)

Xout=X;
idxOut = idx;
% remove poinst on same blob which belongs to 2 cluster the minority
% Step 1: Label the connected components
CC = bwconncomp(bw);

 vec=[1:size(X,1)];

if  0
    labeledImage = labelmatrix(CC);
    % Use label2rgb to assign different colors to labels
    coloredLabels = label2rgb(labeledImage, 'hsv', 'k', 'shuffle');

    % Display the labeled connected components
    figure()
    imshow(coloredLabels);
    title('Connected Components Labeled with Different Colors');

end


indXY = sub2ind(size(bw),X(:,2),X(:,1));
deleteIndeces = [];

% Step 2: Loop through each blob
for blob = 1:CC.NumObjects
    % Step 3: Check for multiple clusters in the blob
    blobIndices = CC.PixelIdxList{blob};
  
   [C,ia,ib] = intersect(indXY,blobIndices );
   clusterIndices = idx(ia);
    
    % Check if there are both clusters 1 and 2 in the blob
    if any(clusterIndices == 1) && any(clusterIndices == 2)
        % Step 4: Determine the minority cluster
        numCluster1 = sum(clusterIndices == 1);
        numCluster2 = sum(clusterIndices == 2);
        
        if numCluster1 < numCluster2
            minorityCluster = 1;
            majority=2;
        else
            minorityCluster = 2;
            majority=1;
        end
        
        % Step 5: Remove the minority points
        %Xout(ia(clusterIndices == minorityCluster), :) = [];
        deleteIndeces = [deleteIndeces; ia(clusterIndices == minorityCluster)];

   % find close blobs with minority cluster
   
    curPoints = X(ia,:);
    vo = setdiff(vec,ia);
    otherPoints = X(vo,:);
    otherclusters = idx(vo);

    idxbad = find(otherclusters==minorityCluster);
    otherPoints = otherPoints(idxbad,:);
    voBadIdx = vo(idxbad);

    % Calculate pairwise distances using pdist2
    maxDistance  =50;
    distances = pdist2(curPoints, otherPoints);
    [rows, cols] = find(distances < maxDistance);

    if(~isempty(cols))
        % Display the indices of the selected points in mSet
        selectedIndices = unique(cols);
        selectedIndices = voBadIdx(selectedIndices);

        deleteIndeces=[deleteIndeces; selectedIndices' ];

    end
    

    end

 

end

if(~isempty(deleteIndeces))
    Xout(deleteIndeces,:) = [];
    idxOut(deleteIndeces) = [];
end