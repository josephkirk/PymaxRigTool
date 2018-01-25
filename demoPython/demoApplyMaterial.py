'''
    Applies a standard material to all nodes in the scene.
    Also shows the use of generator functions in Python.
'''

import MaxPlus


def createSphere():
    obj = MaxPlus.Factory.CreateGeomObject(MaxPlus.ClassIds.Sphere)
    obj.ParameterBlock.Radius.Value = 5.0
    return MaxPlus.Factory.CreateNode(obj)


def solidMaterial(color):
    m = MaxPlus.Factory.CreateDefaultStdMat()
    m.Ambient = color
    m.Diffuse = color
    m.Specular = MaxPlus.Color(1, 1, 1)
    m.Shininess = 0.5
    m.ShinyStrength = 0.7
    return m


def descendants(node):
    for c in node.Children:
        yield c
        for d in descendants(c):
            yield d


def allNodes():
    return descendants(MaxPlus.Core.GetRootNode())


def applyMaterialToNodes(m, nodes=allNodes()):
    for n in nodes:
        n.Material = m

if __name__ == '__main__':
    createSphere()
    m = solidMaterial(MaxPlus.Color(0, 0, 1))
    applyMaterialToNodes(m)
