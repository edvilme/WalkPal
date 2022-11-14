from math import sqrt, pow

from geometry.geometry_points import geometry_pointsGetCentroid, geometry_pointsGetCircleTangents, geometry_pointsGetDistance

class geometry_LineSegment:
    __start: tuple
    __end: tuple
    __length: float
    __gradient: float

    def __init__(self, start: tuple, end: tuple):
        self.__start = start
        self.__end = end
        self.__length = self.__getLength()
        self.__gradient = self.__getGradient()

    def __getLength(self):
        return sqrt( pow(self.start[0]-self.end[0], 2) + pow(self.start[1]-self.end[1], 2))

    def __getGradient(self):
        if self.__start[0] - self.__end[0] == 0:
            return 0
        return (self.__start[1]-self.__end[1])/(self.__start[0]-self.__end[0])

    @property
    def start(self):
        return self.__start
    @property
    def end(self):
        return self.__end
    @property
    def length(self):
        return self.__length
    @property
    def gradient(self):
        return self.__gradient
    @property
    def minX(self):
        return min(self.__start[0], self.__end[0])
    @property
    def minY(self):
        return min(self.__start[1], self.__end[1])
    @property
    def maxX(self):
        return max(self.__start[0], self.__end[0])
    @property
    def maxY(self):
        return max(self.__start[1], self.__end[1])
    @property
    def equationCoefficients(self):
        return (self.__gradient, -1, self.__gradient*self.__start[0] + self.__start[1])
    @property 
    def simpleEquationCoefficients(self):
        return (self.__gradient, - self.__gradient*self.__start[0] + self.__start[1])

    @start.setter
    def start(self, value):
        self.__start = value
        self.__length = self.__getLength()
        self.__gradient = self.__getGradient()

    @end.setter
    def end(self, value):
        self.__end = value
        self.__length = self.__getLength()
        self.__gradient = self.__getGradient()

def geometry_lineDistanceToPoint(line: geometry_LineSegment, point: tuple[float, float]) -> float:
    """# When line is length 0
    #if line.length == 0:
    #    return geometry_pointsGetDistance(line.start, point)
    x1, y1, z1 = line.start
    x2, y2, z2 = line.end
    (x0, y0) = point
    return abs( (x2 - x1)*(y1 - y0) - (x1 - x0)*(y2 - y1) ) / line.length"""
    u = (
        (point[0] - line.start[0]) * (line.end[0] - line.start[0]) +
        (point[1] - line.start[1]) * (line.end[1] - line.start[1])
    ) / pow(line.length, 2)

    x = line.start[0] + u * (line.end[0] - line.start[0])
    y = line.start[1] + u * (line.end[1] - line.start[1])

    return geometry_pointsGetDistance(point, (x, y))



"""def geometry_lineNearbyPoints(line: geometry_LineSegment, points: list, tolerance: float = 0.1) -> list[tuple[float, float]]:
    results = []
    for point in points:
        if geometry_lineDistanceToPoint(line, point["coords"]) < (point["radius"] - tolerance):
            # Avoid if in tip or tail
            if geometry_pointsGetDistance(line.start, point["coords"]) < point["radius"] - tolerance:
                continue
            if geometry_pointsGetDistance(line.end, point["coords"]) < point["radius"] - tolerance:
                continue
            results.append(point)
    return results
"""
def geometry_lineIntersectionPoint(line1: geometry_LineSegment, line2: geometry_LineSegment) -> tuple[float, float]:
    # Case when length is 0 for both
    if line1.length == 0 and line2.length == 0:
        return geometry_pointsGetCentroid([line1.start, line2.start])

    (a, c) = line1.simpleEquationCoefficients
    (b, d) = line2.simpleEquationCoefficients
    if a == b:
        return None
    return ((d - c)/(a - b), a*((d - c)/(a - b)) + c)

def geometry_lineIntersectionAngle(line1: geometry_LineSegment, line2: geometry_LineSegment) -> float:
    #if line1.length == 0 or line2.length == 0:
    #    return 0
    # Center to origin
    originLine1 = geometry_LineSegment((0, 0), (line1.end[0] - line1.start[0], line1.end[1] - line1.end[0]))
    originLine2 = geometry_LineSegment((0, 0), (line2.end[0] - line2.start[0], line2.end[1] - line2.end[0]))
    # Formula
    dotProduct = originLine1.end[0]*originLine2.end[0] + originLine1.end[1]*originLine2.end[1]
    return dotProduct/(originLine1.length*originLine2.length)

def geometry_lineGetCircleTangents(point: tuple[float, float], circleOrigin: tuple[float, float], circleRadius: float) -> list[geometry_LineSegment, geometry_LineSegment]:
    tangentPointA, tangentPointB = geometry_pointsGetCircleTangents(point, circleOrigin, circleRadius)
    return [
        geometry_LineSegment(point, tangentPointA), 
        geometry_LineSegment(point, tangentPointB)
    ]

def geometry_lineGetPointPercentage(line: geometry_LineSegment, point: tuple[float, float], toleranceRadius):
    # See if point is near line
    pointDistanceToLine = geometry_lineDistanceToPoint(line, point)
    # Return -1 if point not within line
    if pointDistanceToLine > toleranceRadius:
        return -1
    # Create segment from start to point
    currentSegment = geometry_LineSegment(line.start, point)
    # Return percentage
    return currentSegment.length / line.length

"""## Util to print
def lines_plot(lines: list, color='red'):
    #figure = plt.figure()
    x_values = [[], []]
    y_values = [[], []]
    for line in lines:
        if line is None:
        continue
        x_values[0].append(line.start[0])
        x_values[1].append(line.end[0])
        y_values[0].append(line.start[1])
        y_values[1].append(line.end[1])
    plt.plot(x_values, y_values, color)"""