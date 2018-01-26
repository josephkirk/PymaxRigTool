'''
    Demonstrates creating objects, object instancing, and object translation.
'''

import MaxPlus


def CreateBorg(obj, n, sz):
    for i in xrange(n):
        for j in xrange(n):
            for k in xrange(n):
                name = "element_{0}_{1}_{2}".format(i, j, k)
                node = MaxPlus.Factory.CreateNode(obj, name)
                pt = MaxPlus.Point3(i * sz, j * sz, k * sz)
                node.Move(pt)


def main():
    obj = MaxPlus.Factory.CreateGeomObject(MaxPlus.ClassIds.Sphere)
    obj.ParameterBlock.Radius.Value = 2.0
    CreateBorg(obj, 4, 5.0)

if __name__ == "__main__":
    main()
