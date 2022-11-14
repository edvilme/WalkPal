from data.data_read import data_getClusters, data_getPoints, data_saveClustersToFile
from geometry.geometry_line import geometry_LineSegment
from geometry.geometry_path import geometry_Path, geometry_PathObstacle, geometry_pathAvoidObstacles, geometry_pathAvoidSingleObstacle
from maps.maps_maps import maps_getDirectionsAvoidingObstacles, maps_searchNear


"""obstacles = [
    geometry_PathObstacle((2, 2), 0.5),
    geometry_PathObstacle((3, 4.5), 1),
    geometry_PathObstacle((4, 2), 1), 
    geometry_PathObstacle((5, 4), 1), 
    geometry_PathObstacle((6, 5), 1), 
    geometry_PathObstacle((7, 8), 0.5), 
    geometry_PathObstacle((7.5, 5.5), 0.5)
]

originalPath = geometry_Path([(0, 0), (9, 9)])

path = geometry_pathAvoidObstacles(originalPath, obstacles, 1)
print(path.points)"""

"""obstacle = geometry_PathObstacle((20, 20), 5)
line = geometry_LineSegment((1, 1), (30, 36))
pathA, pathB = geometry_pathAvoidSingleObstacle(line, obstacle)
print(pathA.points)"""

#data_getClusters("./data")
"""data_saveClustersToFile("./data/data_mexico_city", "./data/data_mexico_city/centroids.csv", 200, file_keys={
    "lat": "latitud_centroide", 
    "lng": "longitud_centroide"
})"""

"""data_saveClustersToFile("./data/data_seattle", "./data/data_seattle/centroids.csv", 100, file_keys={
    "lat": "Latitude", 
    "lng": "Longitude"
})
"""
data_saveClustersToFile("./data/data_austin", "./data/data_austin/centroids.csv", 150, file_keys={
    "lat": "Latitude", 
    "lng": "Longitude"
})