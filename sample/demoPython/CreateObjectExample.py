import MaxPlus
#Create and add Modifier
obj = MaxPlus.Factory.CreateGeomObject(MaxPlus.ClassIds.Cylinder)
obj.ParameterBlock.Radius.Value = 10.0
obj.ParameterBlock.Height.Value = 30.0
node = MaxPlus.Factory.CreateNode(obj)
mod = MaxPlus.Factory.CreateObjectModifier(MaxPlus.ClassIds.Bend)
mod.ParameterBlock.BendAngle.Value = 45.0
node.AddModifier(mod)
# EditMesh
geom = MaxPlus.Factory.CreateGeomObject(MaxPlus.ClassIds.TriMeshGeometry)
tri = MaxPlus.TriObject._CastFrom(geom)
mesh = tri.GetMesh()
