'''
    Lists all the files in a folder
'''
import MaxPlus
import os
pyScriptsDir = os.path.join(MaxPlus.PathManager.GetScriptsDir(), 'python')
for root, dirs, files in os.walk(pyScriptsDir, topdown=False):
    for name in files:
        print name
