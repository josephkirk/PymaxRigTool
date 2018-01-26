'''
    Creates a hierarchy of sphere objects at different relative locations.
'''
import MaxPlus


def createSphere():
    obj = MaxPlus.Factory.CreateGeomObject(MaxPlus.ClassIds.Sphere)
    obj.ParameterBlock.Radius.Value = 5.0
    return MaxPlus.Factory.CreateNode(obj)


def treeOfSpheres(parent, width, xinc, depth, maxdepth):
    if depth == maxdepth:
        return
    for i in range(width):
        n = createSphere()
        n.Parent = parent
        n.SetLocalPosition(MaxPlus.Point3(i * xinc, 0, 15))
        treeOfSpheres(n, width, xinc * width, depth + 1, maxdepth)


def main():
    treeOfSpheres(createSphere(), 2, 10, 0, 4)

if __name__ == "__main__":
    main()
