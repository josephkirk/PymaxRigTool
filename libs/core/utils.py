import MaxPlus as mp
import logging
# log init
logging.basicConfig()
log = logging.getLogger(__name__)
log.setLevel(logging.DEBUG)

def GeneratePlugins(sid, cls):
    Conform_cid = mp.Class_ID(0x1ab13757, 0x12365b98)  # Known bug
    for cd in mp.PluginManager.GetClassList().Classes:
        if cd.SuperClassId == sid and cd.ClassId != Conform_cid:
            o = mp.Factory.CreateAnimatable(sid, cd.ClassId, False)
            if o:
                r = cls._CastFrom(o)
                if r:
                    yield r

def create_ob(nameid, classType='geo', *args, **kws):
    class_dict = {
        'geo': GeneratePlugins(mp.SuperClassIds.GeomObject, mp.GeomObject),
        'shape': GeneratePlugins(mp.SuperClassIds.Shape, mp.ShapeObject),
        'cam': GeneratePlugins(mp.SuperClassIds.Camera, mp.CameraObject),
        'light': GeneratePlugins(mp.SuperClassIds.Light, mp.LightObject),
    }
    search_class = list(class_dict[classType])
    if isinstance(nameid, int):
        try:
            search_object = search_class[nameid]
        except IndexError:
            log.error("Maximum Index is %s"%(len(search_class)-1))
            return
    else:
        search_object = [ob for ob in search_class if nameid.lower() in ob.GetObjectName().lower()]
        search_object = search_object[0] if search_object else None
    log.debug(search_object)
    log.debug([cl.GetObjectName() for cl in search_class])
    if search_object:
        log.info(search_object)
        log.debug(dir(search_object))
        log.debug(search_object.GetClassName())
        for kw, value in kws.items():
            for param in search_object.ParameterBlock:
                if kw.lower() in param.Name.lower():
                    try:
                        param.Value = value
                    except:
                        log.warning("Cannot set %s for %s"%(value, param.Name))
                        # raise
        node = mp.Factory.CreateNode(search_object)
        log.info(node.Name)
        log.debug(dir(node))
        for kw, value in kws.items():
            # Set Node Name
            if kw.lower() in 'name':
                node.SetName(mp.Names.MakeNodeNameUnique(value))
            # Set Postion
            if kw.lower() in "position":
                try:
                    node.Position = mp.Point3(*value)
                except TypeError:
                    node.Delete()
                    raise
            # Set Rotation
            if kw.lower() in "rotate":
                try:
                    matrix = mp.Matrix3()
                    matrix.SetToRotation(*value)
                    log.debug(matrix)
                    node.Rotate(matrix.GetRotation())
                except TypeError:
                    node.Delete()
                    raise
            # Set Scale
        return (node,search_object)
    else:
        log.error("Cannot find %s, Creatable Objects:\n%s"%(
            nameid, str([cl.GetObjectName() for cl in search_class])))

class PyNode(mp.INode):
	def __init__(self, name):
		super(PyNode, self).GetINodeByName(name)