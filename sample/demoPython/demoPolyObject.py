'''
   Demonstrates how to create a mmesh from scratch and to set color per vertex data.
'''
import MaxPlus


def makePyramidMesh(mmesh, side=20.0):
    mmesh.SetNumVerts(4)
    mmesh.SetNumFaces(4)
    mmesh.SetNumEdges(6)
    halfside = side / 2.0
    mmesh.V(0).p = MaxPlus.Point3(0.0, 0.0, side)
    mmesh.V(1).p = MaxPlus.Point3(-halfside, -halfside, 0.0)
    mmesh.V(2).p = MaxPlus.Point3(-halfside, halfside, 0.0)
    mmesh.V(3).p = MaxPlus.Point3(halfside, 0.0, 0.0)
    vislist = MaxPlus.CreateBoolList([1, 1, 0])
    mmesh.F(0).MakePoly(3, MaxPlus.CreateIntList([0, 1, 2]), vislist)
    mmesh.F(1).MakePoly(3, MaxPlus.CreateIntList([0, 2, 3]), vislist)
    mmesh.F(2).MakePoly(3, MaxPlus.CreateIntList([0, 3, 1]), vislist)
    mmesh.F(3).MakePoly(3, MaxPlus.CreateIntList([1, 2, 3]), vislist)
    mmesh.FillInMesh()


def main():
    geom = MaxPlus.Factory.CreateGeomObject(MaxPlus.ClassIds.PolyMeshObject)
    poly = MaxPlus.PolyObject._CastFrom(geom)
    mmesh = poly.mnmesh
    makePyramidMesh(mmesh)
    node = MaxPlus.Factory.CreateNode(poly)
    mmesh.SetMapNum(1)
    mmesh.InitMap(0)

    mmap = mmesh.M(0)
    mmap.SetNumVerts(2)
    mmap.SetV(0, MaxPlus.Point3(1, 0, 0))
    mmap.SetV(1, MaxPlus.Point3(0, 0, 1))
    mmap.F(0).SetTV(MaxPlus.CreateIntList([0, 0, 1]))
    mmap.F(1).SetTV(MaxPlus.CreateIntList([0, 1, 1]))
    mmap.F(2).SetTV(MaxPlus.CreateIntList([1, 1, 1]))
    mmap.F(3).SetTV(MaxPlus.CreateIntList([0, 0, 0]))
    node.VertexColorMode = True

if __name__ == "__main__":
    main()
