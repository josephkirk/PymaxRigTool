'''
    Lists all of the notification codes broadcast by 3ds Max,
    and registers a callback function for each and every one.
'''
import MaxPlus
import os
import sys

codelookup = {}


def listCodes():
    count = 0
    for name in dir(MaxPlus.NotificationCodes):
        if not name.startswith('_'):
            val = getattr(MaxPlus.NotificationCodes, name)
            # we want to avoid registering for
            # define NOTIFY_INTERNAL_USE_START        0x70000000
            if ((type(val) == int) and (val <= 0xFFFF)):
                print "Notification code ", name, " = ", val
                codelookup[val] = name
                count += 1
    print "Number Notifications registered: ", count


def handleNotification(code):
    print "Notification handled: ", codelookup[code]

try:
    listCodes()

    for code in codelookup.iterkeys():
        MaxPlus.NotificationManager.Register(code, handleNotification)

    # Do some things
    print "Creating sphere"
    sphere1 = MaxPlus.Factory.CreateGeomObject(MaxPlus.ClassIds.Sphere)
    print "Setting radius for sphere 1"
    sphere1.ParameterBlock.Radius.Value = 2.0
    print "Creating node for the sphere"
    sphere1node = MaxPlus.Factory.CreateNode(sphere1)
    print "Creating sphere 2"
    sphere2 = MaxPlus.Factory.CreateGeomObject(MaxPlus.ClassIds.Sphere)
    print "Setting radius on sphere 2"
    sphere2.ParameterBlock.Radius.Value = 2.0
    print "Creating node for sphere 2"
    sphere2node = MaxPlus.Factory.CreateNode(sphere2)
    print "Setting parent of node 2 to node 1"
    sphere2node.Parent = sphere1node

    print "Saving file"
    tmpfile = os.path.join(MaxPlus.PathManager.GetTempDir(), "temp.max")
    MaxPlus.FileManager.Save(tmpfile)
    print "Deleting node 1"
    sphere1node.Delete()
    print "Deleting node 2"
    sphere2node.Delete()
    print "Opening file"
    MaxPlus.FileManager.Open(tmpfile)

except Exception, err:
    print 'ERROR: %s\n' % str(err)

except MaxBaseException as e:
    print 'MaxBaseException occured'

except:
    print "Unexpected error:", sys.exc_info()[0]

finally:
    print 'unregistering notification handlers'
    for h in list(MaxPlus.NotificationManager.Handlers):
        MaxPlus.NotificationManager.Unregister(h)
