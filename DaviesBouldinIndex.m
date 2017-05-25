%evaluate optimal number of clusters with Davies–Bouldin index 

% example data
load fisheriris
data = meas(:,3);

% allocate
daviesIndex = zeros(1,15);

for numberOfClusters = 2:15
    try
        % run k-means
        [cluster_ids,cluster_centroids,cluster_distances] = kmeans(data,numberOfClusters,'Distance','sqEuclidean');
        
        pairwise_cluster_distances = squareform(pdist(cluster_centroids,'Euclidean'));
        cluster_populations = arrayfun(@(x) numel(find(cluster_ids == x)),1:numberOfClusters);
        intracluster_distances = cluster_distances./cluster_populations';
        %allocate Davies array
        daviesPerCluster = zeros(1,numberOfClusters);
        for clusNb = 1:numberOfClusters
            davies_temp = zeros(1,numberOfClusters);
            for j=setxor(1:numberOfClusters,clusNb)
                davies_temp(j) = (intracluster_distances(clusNb)+intracluster_distances(j))./pairwise_cluster_distances(j,clusNb);
            end
            daviesPerCluster(clusNb) = max(davies_temp);
        end
        daviesIndex(numberOfClusters) = 1./numberOfClusters*sum(daviesPerCluster);
    catch
        continue; % loop might fail for higher number of clusters
    end
end

%plot results
figure; plot(davies_index(2:end),'r','linewidth',2)

% find optimal number of clusters
optimalNumCluster=find(daviesIndex(2:end)==max(daviesIndex(2:end)))+1;