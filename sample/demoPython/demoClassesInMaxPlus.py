'''
    Demonstrates using the inspect module to list all of the classes in the
    MaxPlus API and the total number of members exposed.
'''

import MaxPlus
import os
import inspect

api = {}
classes = inspect.getmembers(MaxPlus, inspect.isclass)
totalcnt = 0
for c in classes:
    name = str(c[0])
    membercnt = len(c[1].__dict__)
    totalcnt += membercnt
    api[name] = membercnt

fname = os.path.join(MaxPlus.PathManager.GetTempDir(), 'maxplus_api.txt')
with open(fname, 'w') as f:
    for k in sorted(api.keys()):
        f.write(k + " has " + str(api[k]) + " members\n")

print "Results saved to", fname
print "Total number of classes ", len(api)
print "Total number of API elements ", totalcnt
print "Average number of API elements per class ", totalcnt / len(api)
