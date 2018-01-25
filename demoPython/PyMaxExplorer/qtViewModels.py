'''
    view models for 3ds Max object tree
'''
from PySide2 import QtCore
import os

class vmodelMaxObjects(QtCore.QAbstractItemModel):
    def __init__(self, root, parent = None, header = "Scene objects tree"):
        super(vmodelMaxObjects, self).__init__(parent)
        self._header = header
        self._root = root
    
    def index(self, row, column, parent):
        n = self.getNode(parent).child(row)
        if n:
            return self.createIndex(row, column, n)
        else:
            return QtCore.QModelIndex()
    
    def getNode(self, index):
        if not index.isValid() or not index.internalPointer():
            return self._root
        return index.internalPointer()
    
    def columnCount(self, parent):
        return 1

    def rowCount(self, parent):
        parentnode = self._root
        if parent.isValid():
            parentnode = parent.internalPointer()
        return parentnode.numChildren()

    def data(self, index, role):
        if index.isValid() and index.internalPointer() and role == QtCore.Qt.DisplayRole and index.column() == 0:
            return index.internalPointer()._name
    
    def setData(self, index, value, role = QtCore.Qt.EditRole):
        if not index.isValid() or not index.internalPointer() and role != QtCore.Qt.EditRole:
            node.setData(index.column(), value)
            self.dataChanged.emit(index, index)   
            return True
        return False

    def headerData(self, section, orientation, role):
        if role == QtCore.Qt.DisplayRole and section == 0:
            return self._header
        return None
  
    def flags(self, index):
        return QtCore.Qt.ItemIsEnabled | QtCore.Qt.ItemIsSelectable | QtCore.Qt.ItemIsEditable
        
    def parent(self, index):
        parentNode = self.getNode(index).parent()
        if parentNode == self._root:
            return QtCore.QModelIndex()
        return self.createIndex(parentNode.row(), 0, parentNode)
