'''
    Performs a hit test on an object in the active viewport.
'''
import MaxPlus


def main():
    obj = MaxPlus.Factory.CreateGeomObject(MaxPlus.ClassIds.Sphere)
    obj.ParameterBlock.Radius.Value = 50.0
    node = MaxPlus.Factory.CreateNode(obj)
    vp = MaxPlus.ViewportManager.GetActiveViewport()
    hittype = MaxPlus.Constants.HittypeSolid
    hitflags = MaxPlus.Constants.HitAnysolid
    pt = MaxPlus.IPoint2(400, 200)
    hit = obj.HitTest(node, hittype, 1, hitflags, pt, vp)
    print 'hit succes', hit, 'for point', pt
    pt = MaxPlus.IPoint2(0, 0)
    hit = obj.HitTest(node, hittype, 1, hitflags, pt, vp)
    print 'hit success', hit, 'for point', pt

if __name__ == "__main__":
    main()
