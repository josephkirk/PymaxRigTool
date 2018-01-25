
'''
    Demonstrates how to create a QWidget with PySide2 and attach it to the 3dsmax main window.
'''

import os

import MaxPlus
from PySide2 import QtCore
from PySide2 import QtGui
from PySide2 import QtWidgets

class _GCProtector(object):
    widgets = []


def getPosToDockToolBar(dockWidget):
    spaceBetweenWidgets = 20 # Arbritrary hard coded value
    dockWidgetRect = dockWidget.geometry()
    xPos = dockWidgetRect.x()
    yPos = dockWidgetRect.bottom() + spaceBetweenWidgets
    return QtCore.QPoint(xPos, yPos)

def makeToolBarFloating(toolBar, pos):
    toolBar.setWindowFlags(QtCore.Qt.Tool | QtCore.Qt.FramelessWindowHint | QtCore.Qt.X11BypassWindowManagerHint)
    toolBar.move(pos)
    toolBar.adjustSize()
    toolBar.show()
    QtCore.QMetaObject.invokeMethod( toolBar, "topLevelChanged", QtCore.Qt.DirectConnection, QtCore.QGenericArgument("bool", True) );

def make_cylinder():
    obj = MaxPlus.Factory.CreateGeomObject(MaxPlus.ClassIds.Cylinder)
    obj.ParameterBlock.Radius.Value = 10.0
    obj.ParameterBlock.Height.Value = 30.0
    node = MaxPlus.Factory.CreateNode(obj)
    time = MaxPlus.Core.GetCurrentTime()
    MaxPlus.ViewportManager.RedrawViews(time)
    return
    
def main():
    MaxPlus.FileManager.Reset(True)
    mainWindow = MaxPlus.GetQMaxMainWindow()


    # QAction reused by both dockable widgets.
    cylinderIconPath = os.path.dirname(os.path.realpath(__file__)) + "\\demoPySideToolBarCylinderIcon_48.png"
    cylinderIcon = QtGui.QIcon(cylinderIconPath)
    createCylAction = QtWidgets.QAction(cylinderIcon, u"Create Cylinder", mainWindow)
    createCylAction.triggered.connect(make_cylinder)


    # QDockWidget construction and placement over the main window
    dockWidget = QtWidgets.QDockWidget(mainWindow)
    _GCProtector.widgets.append(dockWidget)  # Required to avoid destruction of widget after script has completed execution

    dockWidget.setObjectName("Creators")  # Required for position persistence
    dockWidget.setWindowTitle("Creators") # Required to see dock widget name in toolbar customize popup
    dockToolButton = QtWidgets.QToolButton()
    dockToolButton.setAutoRaise(True)
    dockToolButton.setDefaultAction(createCylAction)
    dockToolButton.setToolButtonStyle(QtCore.Qt.ToolButtonTextOnly)
    dockWidget.setWidget(dockToolButton)

    mainWindow.addDockWidget(QtCore.Qt.LeftDockWidgetArea, dockWidget)
    dockWidget.setFloating(True)
    dockWidget.show()

	
    # QToolBar construction and attachement to main window
    toolBarWidget = QtWidgets.QToolBar(mainWindow)
    _GCProtector.widgets.append(dockWidget)  # Required to avoid destruction of widget afetr script has completed execution

    toolBarWidget.setObjectName("Creators TB")  # Required for position persistence
    toolBarWidget.setWindowTitle("Creators TB") # Required to see toolbar name in toolbar customize popup
    toolBarWidget.setFloatable(True)
    toolBarWidget.addAction(createCylAction)

    mainWindow.addToolBar(QtCore.Qt.BottomToolBarArea, toolBarWidget)
    toolBarWidget.show()

    toolBarPos = getPosToDockToolBar(dockWidget)
    makeToolBarFloating(toolBarWidget, toolBarPos)


app = QtWidgets.qApp
if not app:
    app = QtWidgets.QApplication([])

if __name__ == '__main__':
    main()
