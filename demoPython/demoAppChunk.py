'''
    Demonstrates how to manage user specified data for any object derived from Animatable.
'''
import MaxPlus
import pymxs


def descendants(node):
    for c in node.Children:
        yield c
        for d in descendants(c):
            yield d


def allNodes():
    return descendants(MaxPlus.Core.GetRootNode())


def CreatSceneWithAppChunk():
    MaxPlus.FileManager.Reset(True)

    # Create a teapot, a scene node and a material instance, they are all
    # objects of Animatable
    teapot = MaxPlus.Factory.CreateGeomObject(MaxPlus.ClassIds.Teapot)
    node = MaxPlus.Factory.CreateNode(teapot)
    mtl = MaxPlus.Factory.CreateDefaultStdMat()
    node.Material = mtl
    node.SetName("MyTeapot123")

    # Now add some user specified strings to these objects
    teapot.SetAppData(1234, "I'm a teapot!")
    teapot.SetAppData(2345, u"我是一个茶壶！")

    node.SetAppData(5678, "Node of teapot")
    node.SetAppData(7890, "This is to be removed")
    node.DeleteAppData(7890)

    mtl.SetAppData(4567, "Material of teapot")
    pymxs.runtime.saveMaxFile("scene_with_app_chunk.max")
    print "scene with AppChunk is saved."


def LoadAndCheckSceneWithAppChunk():
    MaxPlus.FileManager.Reset(True)
    pymxs.runtime.loadMaxFile("scene_with_app_chunk.max")
    print "scene with AppChunk is loaded."
    # Find the "MyTeapot123" node
    nodes = allNodes()
    teapotNode = None
    for n in nodes:
        if n.GetName() == "MyTeapot123":
            teapotNode = n
            break
    if teapotNode is None:
        print "Error: Incorrect saved scene."
    else:
        print teapotNode.GetAppData(5678)
        obj = teapotNode.GetObject()
        print obj.GetAppData(1234)
        print obj.GetAppData(2345)
        obj.ClearAllAppData()

        try:
            obj.GetAppData(9432)
        except Exception, e:
            print e
            print "this is expected."
            pass

        try:
            teapotNode.GetAppData(7890)
        except Exception, e:
            print e
            print "this is expected."
            pass

        print teapotNode.Material.GetAppData(4567)

CreatSceneWithAppChunk()
LoadAndCheckSceneWithAppChunk()
