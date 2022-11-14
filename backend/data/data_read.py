from cProfile import label
import math
import numpy as np
import pandas as pd
from pathlib import Path

from sklearn.cluster import KMeans
from clustering.clustering import clustering_CentroidPoint
#from clustering.clustering import clustering_kClusters

from geometry.geometry_points import geometry_pointsFromLatLng, geometry_pointsToLatLng

def data_readFiles(directory: str):
    dfs = []
    for file in Path(directory).glob("911*.csv"):
        print(file.name)
        dfs.append(pd.read_csv(file, encoding='ISO-8859-1'))
    return pd.concat(dfs)

def data_getPoints(directory: str, file_keys: dict):
    points = []
    data = data_readFiles(directory)
    for _, row in data.iterrows():
        if not math.isnan(row[file_keys["lat"]]) and not math.isnan(row[file_keys["lng"]]):
            point = geometry_pointsFromLatLng(row[file_keys["lat"]], row[file_keys["lng"]] )
            points.append(point)
    return points

def data_getClusters(directory: str, n_clusters: int, file_keys: dict):
    points = data_getPoints(directory, file_keys=file_keys)
    print("Clustering: Loaded points from CSV")
    X = np.array(points)
    clusters = KMeans(n_clusters=n_clusters, random_state=0).fit(X)
    print("Clustering: Generated K-Means")

    clusterCentroidPoints: list[clustering_CentroidPoint] = []
    # Store clusters objects
    for centroid in clusters.cluster_centers_:
        cluster = clustering_CentroidPoint( centroid )
        print(cluster.centroid)
        clusterCentroidPoints.append( cluster )
    # Iterate over each point
    for index, clusterIndex in np.ndenumerate(clusters.labels_):
        #print(index[0], clusterIndex)
        clusterCentroidPoints[clusterIndex].addPoint( points[index[0]] )
    # Iterate cluster centroids
    for cluster in clusterCentroidPoints:
        print(cluster.centroid, cluster.radius())
    print("Clustering: Generated clusters and metadata")
    # Return
    return clusterCentroidPoints

def data_saveClustersToFile(directory: str, file: str, n_clusters: int, file_keys: dict):
    data = []
    clusterCentroids = data_getClusters(directory, n_clusters, file_keys=file_keys)
    for centroid in clusterCentroids:
        x, y, z = centroid.centroid
        lat, lng = geometry_pointsToLatLng(x, y, z)

        data.append({
            "centroid_x": x, 
            "centroid_y": y, 
            "centroid_z": z, 
            "centroid_lat": lat, 
            "centroid_lng": lng, 
            "count_points": len(centroid.points), 
            "radius": centroid.radius()
        })
    df = pd.DataFrame(data)
    df.to_csv(file)

def data_getCentroids():
    return pd.concat([
        pd.read_csv("./data/data_mexico_city/centroids.csv"), 
        pd.read_csv("./data/data_austin/centroids.csv"),
        pd.read_csv("./data/data_seattle/centroids.csv"),
    ], ignore_index=True)