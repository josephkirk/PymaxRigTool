import pymxs
import threading
import time

globalArgs = {
    "nativeCallTagA": 1,
    "nativeCallTagB": "",
    "nativeCallWithWrapperObjTagA": 1,
    "nativeCallWithWrapperObjName": u"TestName",
    "wrapObj": None
}


def nativeCall(a, b, localEnv):
    localEnv["nativeCallTagA"] = a
    localEnv["nativeCallTagB"] = b


def nativeWithWrapper(a, wrapObj, localEnv):
    localEnv["nativeCallWithWrapperObjTagA"] = a
    wrapObj.Name = localEnv["nativeCallWithWrapperObjName"]
    localEnv["wrapObj"] = wrapObj


def check(localEnv):
    isSuccess = True
    if localEnv["nativeCallTagA"] != 10 or localEnv["nativeCallTagB"] != "b":
        isSuccess = False
        print "Error: Incorrect native call for threading timer"

    wrapTeapot = localEnv["wrapObj"]
    if localEnv["nativeCallWithWrapperObjTagA"] != 10 or wrapTeapot is None or wrapTeapot.Name != localEnv["nativeCallWithWrapperObjName"]:
        isSuccess = False
        print "Error: Incorrect native call with wrapper object for threading timer"

    return isSuccess


def main():
    global nativeCallTagA, nativeCallTagB
    global nativeCallWithWrapperObjTagA, wrapTeapot

    wrapTeapot = pymxs.runtime.Teapot()

    # test native call
    nativeCallTimer = threading.Timer(0.1, nativeCall, [10, "b"], kwargs={"localEnv": globalArgs})
    nativeWithWrapperTimer = threading.Timer(0.1, nativeWithWrapper, kwargs={
                                             "a": 10, "wrapObj": wrapTeapot, "localEnv": globalArgs})
    print "Start timer"
    nativeCallTimer.start()
    nativeWithWrapperTimer.start()
    time.sleep(0.2)
    if check(globalArgs):
        print "threading timer success"

if __name__ == "__main__":
    main()
