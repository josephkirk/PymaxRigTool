try:
    from PySide import QtCore, QtGui
    QtWidgets = QtGui
except ImportError:
    from PySide2 import QtWidgets, QtCore, QtGui
import MaxPlus

class _GCProtector(object):
    widgets = []

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
    w = QtWidgets.QWidget()
    MaxPlus.AttachQWidgetToMax(w)
    w.resize(250, 100)
    w.setWindowTitle('Window')
    _GCProtector.widgets.append(w)
    w.show()

    main_layout = QtWidgets.QVBoxLayout()
    label = QtWidgets.QLabel("Click button to create a cylinder in the scene")
    main_layout.addWidget(label)

    cylinder_btn = QtWidgets.QPushButton("Cylinder")
    main_layout.addWidget(cylinder_btn)
    w.setLayout(main_layout)
    cylinder_btn.clicked.connect(make_cylinder)
    return w

if __name__ == '__main__':
    try:
        app = QtWidgets.QApplication.instance()
        if not app:
            app = QtWidgets.QApplication([])
    except:
        pass
    main()
    
