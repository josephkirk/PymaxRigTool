'''
    Demonstrates creating instances of a node hierarchy.
'''
import MaxPlus


def createNodes(o, cnt):
    return [MaxPlus.Factory.CreateNode(o) for i in xrange(cnt)]


def linkNodes(nodes):
    for i in xrange(len(nodes) - 1):
        nodes[i + 1].Parent = nodes[i]


def alignNodesInLine(nodes, pt):
    for i in xrange(len(nodes)):
        nodes[i].Move(MaxPlus.Point3(pt.X * i, pt.Y * i, pt.Z * i))


def main():
    obj = MaxPlus.Factory.CreateGeomObject(MaxPlus.ClassIds.Sphere)
    obj.ParameterBlock.Radius.Value = 3.0
    nodes = createNodes(obj, 10)
    alignNodesInLine(nodes, MaxPlus.Point3(5, 0, 0))
    linkNodes(nodes)
    copy = nodes[0].CreateTreeInstance()
    copy.Move(MaxPlus.Point3(0, 25, 0))

if __name__ == "__main__":
    main()
