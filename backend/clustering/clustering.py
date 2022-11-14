from math import floor, inf, sqrt
from geometry.geometry_points import geometry_pointsGetCentroid, geometry_pointsGetDistance


class clustering_CentroidPoint:
    centroid: tuple
    lastCentroid: tuple
    points: list
    def __init__(self, centroid):
        self.centroid = centroid
        self.lastCentroid = None
        self.points = []
    def addPoint(self, point):
        self.points.append(point)
        self.centroid = geometry_pointsGetCentroid(self.points)
    def emptyPoints(self):
        self.lastCentroid = self.centroid
        self.points = []
    def sumOfSquaredErrors(self):
        result = 0
        for point in self.points:
            result += pow(geometry_pointsGetDistance(point, self.centroid), 2)
        return result
    def radius(self):
        result = 0
        for point in self.points:
            result += geometry_pointsGetDistance(point, self.centroid) / len(self.points)
        return result
