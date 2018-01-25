import MaxPlus
import os
from PySide2.QtWidgets import QTabWidget

class TestWidget(QTabWidget):
    def __init__(self, ui_class, parent=None):
        QTabWidget.__init__(self, parent)
        self.ui= ui_class()
        self.ui.setupUi(self)

def test_load_ascii_ui_path(ui_path):
    ui_class, base_class = MaxPlus.LoadUiType(ui_path)
    instance = TestWidget(ui_class)
    instance.show()
    instance.close()

def test_load_ui():
    ui_path = os.path.join(os.path.dirname(__file__), "test_ui.ui")
    test_load_ascii_ui_path(ui_path)
    # test unicode encoding
    test_load_ascii_ui_path(u'%s' % ui_path)
    # test a unicode encoding with non-ascii characters
    try:
        test_load_ascii_ui_path(u'D:/你好')
    except UnicodeEncodeError:
        pass
    else:
        print "Error: unexpected exception"


if __name__ == "__main__":
    test_load_ui()
