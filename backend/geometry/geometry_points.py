from math import asin, atan2, degrees, radians, sqrt, pi, sin, cos, atan, acos

def geometry_pointsFromLatLng(lat, lng) -> tuple[float, float, float]:
    R = 6378137.0
    latRadians = radians(lat)
    lngRadians = radians(lng)

    x = R * cos(latRadians)*cos(lngRadians)
    y = R * cos(latRadians)*sin(lngRadians)
    z = R * sin(latRadians)
    return x, y, z

def geometry_pointsToLatLng(x, y, z) -> tuple[float, float]:
    r = sqrt( x**2 + y**2 + z**2 )
    latRadians = asin(z/r)
    lngRadians = atan2(y, x)
    lat = degrees(latRadians)
    lng = degrees(lngRadians)
    return lat, lng


def geometry_pointsGetCentroid(points: list[tuple[float, float]]) -> tuple[float, float, float]:
    xCoord, yCoord, zCoord = 0, 0, 0
    for point in points:
        xCoord += point[0] / len(points)
        yCoord += point[1] / len(points)
        if len(point) == 3:
            zCoord += point[2] / len(points)
    return (xCoord, yCoord, zCoord)

def geometry_pointsGetDistance(pointA: tuple[float, float], pointB: tuple[float, float]) -> float:
    return sqrt( pow(pointA[0] - pointB[0], 2) + pow(pointA[1] - pointB[1], 2) )


def geometry_pointsGetCircleTangents(point: tuple[float, float], circleOrigin: tuple[float, float], circleRadius: tuple) -> list[tuple[float, float], tuple[float, float]]:
    # Case when radius or point inside circle
    if geometry_pointsGetDistance(point, circleOrigin) <= circleRadius:
        return [point, point]
    # Get coords (centered at origin)
    x1 = point[0] - circleOrigin[0]
    y1 = point[1] - circleOrigin[1]
    sign = x1/abs(x1)
    # Get distance 
    distance = geometry_pointsGetDistance((0, 0), (x1, y1))
    # Get angles
    beta = atan(y1/x1)
    alpha = acos(circleRadius/distance)
    # Return points
    return [
        (sign*circleRadius*cos(beta + alpha) + circleOrigin[0], sign*circleRadius*sin(beta + alpha) + circleOrigin[1]), 
        (sign*circleRadius*cos(beta - alpha) + circleOrigin[0], sign*circleRadius*sin(beta - alpha) + circleOrigin[1])
    ]