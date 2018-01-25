'''
An example of how to populate RNormals and get them with GetRenderedVertexNormals()
'''
import MaxPlus

obj = MaxPlus.Factory.CreateGeomObject(MaxPlus.ClassIds.Box)
n = MaxPlus.Factory.CreateNode(obj, "myBox")

print "node name: %s" % n.Name
n.Convert(MaxPlus.ClassIds.TriMeshGeometry)
object_state = n.EvalWorldState()
obj_original = object_state.Getobj()
tri_obj = MaxPlus.TriObject._CastFrom(obj_original)
tri_mesh = tri_obj.GetMesh()
print "normals built? ", tri_mesh.GetNormalsBuilt() # will return 0 if normals are not yet built
tri_mesh.CheckNormals(True) # less expensive than BuildNormals(), because it will only build if normals
# do not yet exist
print "normals built? ", tri_mesh.GetNormalsBuilt() # will now return non-0 because CheckNormals() ensures
# we've built them
normal_count = tri_mesh.GetNormalCount()
vertex_count = tri_mesh.GetNumVertices()
print " normals: ", normal_count
print " verts: ", vertex_count

for i in range(0, vertex_count):
	print "vertex: " , tri_mesh.GetVertex(i)
	print "RNormal: ", tri_mesh.GetRenderedVertexNormal(i)
