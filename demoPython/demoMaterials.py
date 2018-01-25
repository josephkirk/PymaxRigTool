'''
    Demonstrates how to iterate through materials and and apply them to objects.
    It shows how to open the material editor and put materials in the editor.
'''
import MaxPlus
import math


def GeneratePlugins(sid, cls):
    for cd in MaxPlus.PluginManager.GetClassList().Classes:
        if cd.SuperClassId == sid:
            anim = MaxPlus.Factory.CreateAnimatable(sid, cd.ClassId, False)
            if anim:
                inst = cls._CastFrom(anim)
                if inst:
                    yield inst


def CreateMaterials():
    materials = GeneratePlugins(MaxPlus.SuperClassIds.Material, MaxPlus.Mtl)
    materialList = list(materials)
    numMaterials = len(materialList)
    # for m in materialList:
    #    print m
    print "%d materials" % numMaterials
    return materialList


def CreatePlane():
    plane = MaxPlus.Factory.CreateGeomObject(MaxPlus.ClassIds.Plane)
    plane.ParameterBlock.Width.Value = 120.0
    plane.ParameterBlock.Length.Value = 120.0
    node = MaxPlus.Factory.CreateNode(plane)


def PrintMaterialProperties(material_instance):
    print "[%s] %s" % (material_instance.GetClassName(), material_instance.GetName())
    for p in material_instance.ParameterBlock.Parameters:
        print "\t" + p.Name + " = " + str(p.Value)


def CreateText(x, y, quat, message):
    tex = MaxPlus.Factory.CreateShapeObject(MaxPlus.ClassIds.text)
    tex.ParameterBlock.size.Value = 10.0
    tex.ParameterBlock.text.Value = message
    node = MaxPlus.Factory.CreateNode(tex)
    node.Position = MaxPlus.Point3(x, y, 0)
    node.SetLocalRotation(quat)
    node.WireColor = MaxPlus.Color(1.0, 0.5, 1.0)


class MtlDlgMode(object):
    ''' Enumeration that determines what kind of material dialog to display'''
    basic = 0    # Basic mode, basic parameter editing of material and textures
    advanced = 1  # Advanced mode, schematic graph editing of material and texture connections


def CreateAndAssignMaterials(materials):
    numMaterials = len(materials)
    diff = 360.0 / numMaterials
    teapot_radius = 5.0
    radius = 50.0
    text_radius = 90.0
    index = 0
    i = 0
    MaxPlus.MaterialEditor.OpenMtlDlg(MtlDlgMode.basic)

    for m in materials:
        angle_radians = math.radians(i)
        x = radius * math.cos(angle_radians)
        y = radius * math.sin(angle_radians)
        position = MaxPlus.Point3(x, y, 0)

        teapot = MaxPlus.Factory.CreateGeomObject(MaxPlus.ClassIds.Teapot)
        teapot.ParameterBlock.Radius.Value = teapot_radius
        node = MaxPlus.Factory.CreateNode(teapot)
        node.Position = position
        angle_rotate = 180 - i
        angle_axis_rotation = MaxPlus.AngAxis(
            0, 0, 1, math.radians(angle_rotate))
        quat = MaxPlus.Quat(angle_axis_rotation)
        node.SetLocalRotation(quat)

        x = text_radius * math.cos(angle_radians)
        y = text_radius * math.sin(angle_radians)
        CreateText(x, y, quat, m.GetClassName())
        if (index < 24):
            MaxPlus.MaterialManager.PutMtlToMtlEditor(m, index)
            MaxPlus.MaterialEditor.SetSlot(index, m)
            MaxPlus.MaterialEditor.UpdateMtlEditorBrackets()
            MaxPlus.MaterialEditor.SetActiveSlot(index)
            MaxPlus.MaterialEditor.FlushMtlDlg()

        # Now assign the material
        node.Material = m
        PrintMaterialProperties(m)
        i += diff
        index += 1
    MaxPlus.MaterialEditor.FlushMtlDlg()


def DoStuff():
    MaxPlus.FileManager.Reset(True)
    # maximize the view
    MaxPlus.ViewportManager.SetViewportMax(True)
    CreatePlane()
    materials = CreateMaterials()
    CreateAndAssignMaterials(materials)

DoStuff()
