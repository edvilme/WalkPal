import json
from math import sqrt
import googlemaps
import pandas as pd
from data.data_read import data_getCentroids
import polyline

from geometry.geometry_path import geometry_Path, geometry_PathObstacle, geometry_lineGetObstacles, geometry_pathAvoidObstacles, geometry_pathGetDifferences
from geometry.geometry_points import geometry_pointsFromLatLng, geometry_pointsToLatLng
gmaps = googlemaps.Client(key="GOOGLE-MAPS-KEY-HERE-1")



# Get maps obstacles
mapObstacles = []
mapsObstaclesRaw = data_getCentroids()


for _, row in mapsObstaclesRaw.iterrows():
    mapObstacles.append( 
        geometry_PathObstacle((row["centroid_x"], row["centroid_y"]), sqrt(row["radius"])) 
    )

def maps_getDirectionsWaypoints(start, destination):
    Waypoints = []
    directions = gmaps.directions(start, destination, mode="walking")[0]
    steps = directions['legs'][0]['steps']
    for step in steps:
        """# Get start coords (in x, y)
        startX, startY, startZ = geometry_pointsFromLatLng( step["start_location"]["lat"], step["start_location"]["lng"] )
        endX, endY, endZ = geometry_pointsFromLatLng( step["end_location"]["lat"], step["end_location"]["lng"] )

        # Get decoded points
        decoded_points = polyline.decode(step["polyline"]["points"])
        stepPathLatLng = geometry_Path(decoded_points)
        stepPath = stepPathLatLng.getXYPoints()

        step_obstacles = []
        for line in stepPath.lines:
            line_obstacles = geometry_lineGetObstacles(line, mapObstacles, 5)
            for obstacle in line_obstacles:
                step_obstacles.append(obstacle)

        stepPathNoObstacles = geometry_pathAvoidObstacles(stepPath, step_obstacles, 0)

        waypoints_tmp = geometry_pathGetDifferences(stepPath, stepPathNoObstacles)
        for point in waypoints_tmp:
            Waypoints.append(point)"""
        startX, startY, startZ = geometry_pointsFromLatLng( step["start_location"]["lat"], step["start_location"]["lng"] )
        endX, endY, endZ = geometry_pointsFromLatLng( step["end_location"]["lat"], step["end_location"]["lng"] )
        stepPath = geometry_Path([(startX, startY), (endX, endY)])
        obstacles = geometry_lineGetObstacles(stepPath.lines[0], mapObstacles, 2)
        stepPathNoObstacles = geometry_pathAvoidObstacles(stepPath, obstacles, 0)
        for point in geometry_pathGetDifferences(stepPath, stepPathNoObstacles):
            Waypoints.append(point)

    print(Waypoints)
    return Waypoints

def maps_getDirectionsAvoidingObstacles(start, destination):
    # Get waypoints
    waypoints = maps_getDirectionsWaypoints(start, destination)
    waypoints_str = list(map(lambda p: "via:" + str(p[0]) + "," + str(p[1]), waypoints))
    # Get directions
    directions = gmaps.directions(start, destination, mode="walking", waypoints=waypoints_str)
    # Overview poliline 
    for step in directions[0]["legs"][0]["steps"]:
        step["polyline"]["decoded_points"] = polyline.decode(step["polyline"]["points"])

    # print(json.dumps(directions))
    return directions[0]


def maps_searchNear(input, latitude, longitude):
    # Get places
    data = gmaps.places(
        input, 
        location = f"${latitude}, ${longitude}"
    )
    return data["results"]
