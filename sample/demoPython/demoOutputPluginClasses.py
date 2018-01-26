'''
    Demonstrates using the PluginManager to extract information about loaded plugins.
'''
import MaxPlus

# List all plug-in dlls
pluginsDlls = MaxPlus.PluginManager.PluginDlls
print "Total PluginDlls: {0}\n".format(MaxPlus.PluginManager.GetNumPluginDlls())
for pd in pluginsDlls:
    print "PluginDll:", pd.FilePath
    print "Description:", pd.Description
    print "Loaded:", pd.Loaded
    print "NumClasses:", pd.NumClasses
    for cd in pd.Classes:
        if cd:
            print "  ", cd.GetClassName()
