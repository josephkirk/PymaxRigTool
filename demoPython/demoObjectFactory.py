'''
    Demonstrates using the Factory to create objects and associate them with nodes.
'''
import MaxPlus

# Get the class ID for the conform object which is known to not work properly
Conform_cid = MaxPlus.Class_ID(0x1ab13757, 0x12365b98)

# Enumerate over all classes loaded by 3ds Max
for cd in MaxPlus.PluginManager.GetClassList().Classes:
    if cd.SuperClassId == MaxPlus.SuperClassIds.GeomObject:
        try:
            # Skip over the conform object
            if cd.ClassId != Conform_cid:

                print 'creating ', cd.Name
                # Create the object
                o = MaxPlus.Factory.CreateGeomObject(cd.ClassId)
                if o:
                    print 'successful'
                    # Create a node and associate the object with it.
                    MaxPlus.Factory.CreateNode(o)
                else:
                    print 'failed'
            else:
                print "The Conform object can't be created"
        except:
            print 'Error occured'
