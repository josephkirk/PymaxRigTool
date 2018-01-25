version_data = {}

try:
    from sys import version, prefix
    version_data['sys module'] = True
    version_data['Python version'] = version
    version_data['Python prefix'] = prefix
except:
    version_data['sys module'] = False

try:
    import os
    version_data['os module'] = True
    version_data['3ds Max 2017 path environment variable'] = os.getenv(
        "ADSK_3DSMAX_x64_2017")
except:
    version_data['os module'] = False

try:
    import MaxPlus
    version_data['MaxPlus module'] = True
    version_data['3ds Max install path'] = MaxPlus.PathManager.GetMaxSysRootDir()
    version_data['MaxPlus version'] = MaxPlus.__version__
except:
    version_data['MaxPlus module'] = False

try:
    import PySide2
    import PySide2.QtCore
    version_data['PySide2 module'] = True
    version_data['PySide2 version'] = PySide2.__version__
    # NOTE: if PyQt is loaded succesfully first, this may return a
    # different version of Qt if the PySide2 Qt is different.
    # it will just load the DLLs that it found.
    version_data['PySide2 Qt version'] = PySide2.QtCore.__version__
except:
    version_data['PySide2 module'] = False

for key in sorted(version_data):
    print key, version_data[key]
