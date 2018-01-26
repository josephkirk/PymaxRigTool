'''
    Creates a number of boxes with random scale, position, and rotation.
'''
import random
import math
import MaxPlus


def rnd():
    return random.random()


def rndAngle():
    return -math.pi + (rnd() * 2 * math.pi)


def rndQuat():
    return MaxPlus.Quat(rnd(), rnd(), rnd(), rndAngle())


def rndDist():
    return rnd() * 100.0 - 50.0


def rndPosition():
    return MaxPlus.Point3(rndDist(), rndDist(), 0)


def rndScaleAmount():
    return rnd() * 2.0 + 0.1


def rndScale():
    return MaxPlus.Point3(rndScaleAmount(), rndScaleAmount(), rndScaleAmount())


def randomTransformNodes(nodes):
    for n in nodes:
        n.Scaling = rndScale()
        n.Rotation = rndQuat()
        n.Position = rndPosition()


def createNodes(obj, cnt):
    return [MaxPlus.Factory.CreateNode(obj) for i in range(cnt)]


def main():
    box = MaxPlus.Factory.CreateGeomObject(MaxPlus.ClassIds.Box)
    box.ParameterBlock.Length.Value = 10.0
    box.ParameterBlock.Height.Value = 10.0
    box.ParameterBlock.Width.Value = 10.0
    nodes = createNodes(box, 25)
    randomTransformNodes(nodes)

if __name__ == "__main__":
    main()
