import MaxPlus
fm = MaxPlus.FileManager
fm.Save(MaxPlus.PathManager.GetTempDir() + r"\test.max")
print fm.GetFileNameAndPath()
