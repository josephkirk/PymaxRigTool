'''
    UI platform which demostrate the PySide2 ui loading and 
    display  object tree on explorer.
                                        -Feng Du
'''
import os, sys
from PySide2 import QtCore, QtWidgets
import MaxPlus
import pymxs
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from maxDataModels import mxTreeNode
from qtViewModels import vmodelMaxObjects

rt = pymxs.runtime
uitype, basetype = MaxPlus.LoadUiType(os.path.join(os.path.dirname(__file__),'mainUI.ui'))

class PyMaxExplorer(basetype,uitype):
    def __init__(self, parent=None):
        super(PyMaxExplorer,self).__init__(parent)
        self.setupUi(self)
        self.buildViewModel()
        self.connectActions()
        self.setupMaxCallbacks()

    def setupMaxCallbacks(self):
        self._callbackItem = rt.NodeEventCallback(all=self.cbNodeEvent)
        
    def teardownMaxCallbacks(self):
        self._callbackItem = None

    def buildViewModel(self):
        self._rootNode = self.buildTree(rt.rootNode)
        self._proxyModel = QtCore.QSortFilterProxyModel()
        self._model = vmodelMaxObjects(self._rootNode)
        self._proxyModel.setSourceModel(self._model)
        self._proxyModel.setDynamicSortFilter(True)
        self._proxyModel.setFilterCaseSensitivity(QtCore.Qt.CaseInsensitive)
        self.treeView_objects.setModel(self._proxyModel)
        self.treeView_objects.setSortingEnabled(True)	   
        QtCore.QObject.connect(self.uiGraphFilter, QtCore.SIGNAL("textChanged(QString)"), self._proxyModel.setFilterRegExp)
   
    def connectActions(self):
        self.connect(self.actionWatch, QtCore.SIGNAL('triggered()'),self.actWatch)
        self.connect(self.actionAbout, QtCore.SIGNAL('triggered()'),self.actAbout)
        self.connect(self.actionRefresh, QtCore.SIGNAL('triggered()'),self.actRefresh)
        self.connect(self.actionExit, QtCore.SIGNAL('triggered()'),self.actExit)
        self.connect(self.actionUndo, QtCore.SIGNAL('triggered()'),self.actUndo)
        self.connect(self.actionRedo, QtCore.SIGNAL('triggered()'),self.actRedo)

    def actWatch(self):
        self.Watcher.show()

    def actAbout(self):
        QtWidgets.QMessageBox.about(self, "PyMaxExplorer 1.0", "PyMaxExplorer is a demo for pymxs and PySide usage on 3ds Max")

    def actRefresh(self):
        self.buildViewModel()

    def actExit(self):
        self.close()

    def actUndo(self):
        pymxs.run_undo()

    def actRedo(self):
        pymxs.run_redo()
        
    def cbNodeEvent(self, event, node):
        self.buildViewModel()
    
    def buildTree(self, mxObj, parent = None, userName = ''):
        nodeName = mxObj.name
        if userName:
            nodeName = userName
        newNode = mxTreeNode(nodeName, parent)
        for c in mxObj.children:
            self.buildTree(c, newNode)
        return newNode
