'''
Demonstrates combining the mesh of two scene nodes
'''
from PySide2 import QtWidgets
import MaxPlus

app = QtWidgets.qApp
if not app:
    app = QtWidgets.QApplication([])
    
class _GCProtector(object):
    widgets = []

def GetObjectMesh(node):
    node.Convert(MaxPlus.ClassIds.TriMeshGeometry)
    object_state = node.EvalWorldState()
    obj_original = object_state.Getobj()
    tri_obj = MaxPlus.TriObject._CastFrom(obj_original)    
    tri_mesh = tri_obj.GetMesh()
    return tri_mesh

def CombineNodes():
    if MaxPlus.SelectionManager.GetCount() !=2:
        msg = "Please select 2 nodes to combine."
        print msg
        show_alert(msg)
    else:
        node1 = MaxPlus.SelectionManager.GetNode(0)
        node2 = MaxPlus.SelectionManager.GetNode(1)
        a = GetObjectMesh(node1)
        b = GetObjectMesh(node2)
        # create a new, empty mesh for the combined meshes:
        new_obj = MaxPlus.Factory.CreateNewTriObject()
        new_node = MaxPlus.Factory.CreateNode(new_obj)
        new_mesh=new_obj.GetMesh()    
        # combine a and b into the new mesh:
        MaxPlus.Mesh.CombineMeshes(new_mesh,a,b)

def show_alert(message):
    msgBox = QtWidgets.QMessageBox()
    msgBox.setText(message)
    msgBox.exec_()

def main():
    w = QtWidgets.QWidget(MaxPlus.GetQMaxMainWindow())
    _GCProtector.widgets.append(w)
    w.resize(250, 100)
    w.setWindowTitle('Combine 2 Nodes')

    main_layout = QtWidgets.QVBoxLayout()
    label = QtWidgets.QLabel("Combine 2 Nodes")
    main_layout.addWidget(label)

    combine_btn = QtWidgets.QPushButton("Combine")
    combine_btn.clicked.connect(CombineNodes)
    main_layout.addWidget(combine_btn)

    w.setLayout(main_layout)
    w.show()


if __name__ == '__main__':
    main()