'''
    Demonstrates calling a MAXScript expression and getting a node value from it.
'''
import MaxPlus
obj = MaxPlus.Factory.CreateGeomObject(MaxPlus.ClassIds.Cone)
obj.ParameterBlock.radius1.Value = 5.0
obj.ParameterBlock.radius2.Value = 10.0
node = MaxPlus.Factory.CreateNode(obj)
node.Name = 'PythonCone001'
r = MaxPlus.Core.EvalMAXScript('$' + node.Name)
print r.Type, r.Get()
