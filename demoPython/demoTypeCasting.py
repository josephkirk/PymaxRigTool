'''
    Demonstrates how to cast an instance of Animatable to another type based on its SuperClassID
'''
import MaxPlus

SuperIdTypes = {
    MaxPlus.SuperClassIds.Osm: MaxPlus.Modifier,
    MaxPlus.SuperClassIds.Wsm: MaxPlus.Modifier,
    MaxPlus.SuperClassIds.Helper: MaxPlus.HelperObject,
    MaxPlus.SuperClassIds.GeomObject: MaxPlus.GeomObject,
    MaxPlus.SuperClassIds.Light: MaxPlus.LightObject,
    MaxPlus.SuperClassIds.Texmap: MaxPlus.Texmap,
    MaxPlus.SuperClassIds.Material: MaxPlus.Mtl,
    MaxPlus.SuperClassIds.Atmospheric: MaxPlus.Atmospheric,
    MaxPlus.SuperClassIds.SoundObj: MaxPlus.SoundObj,
    MaxPlus.SuperClassIds.Renderer: MaxPlus.Renderer}


def descendants(node):
    for c in node.Children:
        yield c
        for d in descendants(c):
            yield d


def allNodes():
    return descendants(MaxPlus.Core.GetRootNode())


def castObject(o):
    if not o:
        return None
    sid = o.GetSuperClassID()
    if sid not in SuperIdTypes:
        return None
    return SuperIdTypes[sid]._CastFrom(o)

for n in allNodes():
    cast = castObject(n.Object)
    if cast:
        print type(cast)
