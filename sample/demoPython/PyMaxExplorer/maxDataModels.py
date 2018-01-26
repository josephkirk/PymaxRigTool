'''
    Data model for 3ds Max node.
'''
from pymxs import runtime as rt

class mxTreeNode(object):
    def __init__(self, name ,parent=None):
        self._name = name
        self._children = []	
        self._parent = parent
        if self._parent and self not in self._parent._children :
            self._parent._children.append(self)

    def getName(self): 
        return self._name

    def setName(self, nm):
        self._name = nm

    name = property(getName, setName)
    
    def mxNode(self):
        obj = rt.getNodeByName(self._name)
        return obj

    def mxType(self):
        return str(rt.classOf(self._node))
    
    def row(self):
        if self._parent:
            return self._parent._children.index(self)
        return 0

    def parent(self):
        return self._parent  

    def child(self, indx):
        if self._children and indx >= 0 and indx < self.numChildren():
            return self._children[indx]
        return None

    def numChildren(self):
        return len(self._children)
        
    def addChild(self, child):
        self._children.append(child)  

    def insertChild(self, node, pos):
        if pos >= 0 and pos < self.numChildren():
            self._children.insert(pos, node)
            node._parent = self
            return True
        return False
    
    def popChild(self, pos):
        if pos >= 0 and pos < self.numChildren():
            child = self._children.pop(pos)
            child._parent = None
            return True
        return False        
