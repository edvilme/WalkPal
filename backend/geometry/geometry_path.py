
from geometry.geometry_line import geometry_LineSegment, geometry_lineDistanceToPoint, geometry_lineGetCircleTangents, geometry_lineIntersectionPoint
from geometry.geometry_points import geometry_pointsFromLatLng, geometry_pointsGetDistance

class geometry_PathObstacle:
    coords: tuple[float, float]
    radius: float
    def __init__(self, coords, radius) -> None:
        self.coords = coords
        self.radius = radius

class geometry_Path:
    __points = []
    __lines = []
    __length = 0
    def __init__(self, points):
        self.__points = []
        for point in points:
            self.addPoint(point)

    def addPoint(self, point):
        self.__points.append(point)
        self.__lines = []
        self.__length = 0
        if len(self.__points) < 2:
            pass
        for i in range(1, len(self.__points)):
            line = geometry_LineSegment(self.__points[i-1], self.__points[i])
            self.__lines.append(line)
            self.__length += line.length

    def popPoint(self):
        self.__points.pop()
        self.__lines = []
        self.__length = 0
        if len(self.__points) < 2:
            pass
        for i in range(1, len(self.__points)):
            line = geometry_LineSegment(self.__points[i-1], self.__points[i])
            self.__lines.append(line)
            self.__length += line.length

    def getXYPoints(self):
        points = []
        for point in self.points:
            points.append( geometry_pointsFromLatLng(point[0], point[1]) )
        return geometry_Path(points)

    @property
    def points(self) -> list[tuple]:
        return self.__points

    @property
    def lines(self):
        return self.__lines

    @property
    def length(self):
        return self.__length

def geometry_pathGetDifferences(basePath: geometry_Path, comparePath: geometry_Path) -> list[tuple]:
    differences = set(basePath.points) - set(comparePath.points)
    return differences

def geometry_lineGetObstacles(line: geometry_LineSegment, obstacles: list[geometry_PathObstacle], tolerance: float = 5) -> list[geometry_PathObstacle]:
    results = []
    for obstacle in obstacles:
        if geometry_lineDistanceToPoint(line, obstacle.coords) < (obstacle.radius) - tolerance:
            # Avoid tip or tail
            if geometry_pointsGetDistance(line.start, obstacle.coords) < (obstacle.radius) - tolerance:
                continue
            if geometry_pointsGetDistance(line.end, obstacle.coords) < (obstacle.radius) - tolerance:
                continue
            results.append(obstacle)
    return results

def geometry_pathAvoidSingleObstacle(line: geometry_LineSegment, obstacle: geometry_PathObstacle) -> list[geometry_Path, geometry_Path]:
    # Create empty paths
    pathAlpha = geometry_Path([line.start])
    pathBeta = geometry_Path([line.start])
    # If head or tail is in obstacle
    if geometry_pointsGetDistance(line.start, obstacle.coords) <= obstacle.radius or geometry_pointsGetDistance(line.end, obstacle.coords) <= obstacle.radius:
        pass
    # If line passes through obstacle
    elif geometry_lineDistanceToPoint(line, obstacle.coords) <= obstacle.radius:
        # Get tangent lines
        tangentA, tangentB = geometry_lineGetCircleTangents(line.start, obstacle.coords, obstacle.radius)
        tangentC, tangentD = geometry_lineGetCircleTangents(line.end, obstacle.coords, obstacle.radius)
        # Get intersections between tangents
        intersectionAC = geometry_lineIntersectionPoint(tangentA, tangentC)
        intersectionAD = geometry_lineIntersectionPoint(tangentA, tangentD)
        intersectionBC = geometry_lineIntersectionPoint(tangentB, tangentC)
        intersectionBD = geometry_lineIntersectionPoint(tangentB, tangentD)
        # Get two intersections closest to obstacle
        intersectionA = intersectionAC if geometry_pointsGetDistance(obstacle.coords, intersectionAC) < geometry_pointsGetDistance(obstacle.coords, intersectionAD) else intersectionAD
        intersectionB = intersectionBC if geometry_pointsGetDistance(obstacle.coords, intersectionBC) < geometry_pointsGetDistance(obstacle.coords, intersectionBD) else intersectionBD
        # Add to path
        pathAlpha.addPoint(intersectionA)
        pathBeta.addPoint(intersectionB)
    pathAlpha.addPoint(line.end)
    pathBeta.addPoint(line.end)
    return [pathAlpha, pathBeta]

def geometry_pathAvoidObstacles(path: geometry_Path, obstacles: list, it, tolerance=1):
    if it >= len(obstacles) / 2:
        return path
    # Get last line
    line = path.lines[-1]
    # Get last obstacle
    nearObstacles = geometry_lineGetObstacles(line, obstacles, tolerance)
    obstacle = nearObstacles[0] if len(nearObstacles) > 0 else None
    # Stop if no obstacle
    if obstacle is None:
        return path
    # Get next paths
    nextPathA, nextPathB = geometry_pathAvoidSingleObstacle(line, obstacle)
    pathA = geometry_Path(path.points[0:-2] + nextPathA.points)
    pathB = geometry_Path(path.points[0:-2] + nextPathB.points)
    # Return if no changes or deviations
    if pathA.length == line.length:
        return pathA
    if pathB.length == line.length:
        return pathB
    # Recurse
    a = geometry_pathAvoidObstacles(pathA, obstacles, it+1)
    b = geometry_pathAvoidObstacles(pathB, obstacles, it+1)
    # Return shortest path
    """if a.length < b.length:
        return a
    else:
        return b"""
    if len(a.points) < len(b.points):
        return a
    else: 
        return b