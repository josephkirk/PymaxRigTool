'''
    Creates all geometric objects and lists their parameters.
'''
import MaxPlus
import sys

for cd in MaxPlus.PluginManager.GetClassList().Classes:
    if cd.SuperClassId == MaxPlus.SuperClassIds.GeomObject:
        print 'Create class ', cd.Name
        o = MaxPlus.Factory.CreateGeomObject(cd.ClassId)
        i = 0
        for p in o.ParameterBlock:
            type_name = MaxPlus.FPTypeGetName(p.Type)
            try:
                print '  parameter', i, p.Name, p.Type, type_name, p.Value
                i += 1
            except:
                etype, evalue = sys.exc_info()[:2]
                print 'error ', etype, evalue
