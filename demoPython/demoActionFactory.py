import MaxPlus

somethingHappened = False


def doSomething():
    global somethingHappened
    somethingHappened = True
    print "I sleep all night and I work all day!"


def printAction(a):
    print "id ", a.Id
    print "button text ", a.ButtonText
    print "menu text ", a.MenuText
    print "description ", a.Description
    print "category ", a.Category
    print "checked ", a.Checked
    print "indeterminate ", a.Indeterminate
    print "visible ", a.Visible
    print "enabled ", a.Enabled
    print "dynamic ", a.Dynamic
    print "shortcut ", a.Shortcut

action = MaxPlus.ActionFactory.Create(
    'Do something', 'Python demo', doSomething)
printAction(action)

assert(not somethingHappened)
action.Execute()
assert(somethingHappened)
action.Execute()
assert(somethingHappened)
