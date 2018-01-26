import sys
import os
import MaxPlus

# Use PyMaxModule 
old_path = sys.path
ScriptPath = os.path.dirname(__file__)
sys.path.append(ScriptPath)
from PyMaxExplorer.explorer import PyMaxExplorer

# This make PyMaxExplorer attached to Max MainWindow 
tool = PyMaxExplorer(MaxPlus.GetQMaxMainWindow())
tool.show()

# Revert system path
sys.path = old_path