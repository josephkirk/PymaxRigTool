import pymxs
import threading
import time

flag = True
counter = 0

def callMXSEntry():
    with pymxs.mxstoken():
        pymxs.runtime.Teapot()

# Ex1 and Ex2 used to mark cooperator of mxstoken
# when pymxs.mxstoken is gained
#    python codes are concurrence, but with pymxs.mxstoken blocks are not
#
def callMXSEntryEx1(locker, tick, evt):
    global flag, counter

    try:
        locker.acquire()
        flag = False
        with pymxs.mxstoken():
            pymxs.runtime.Teapot(Name="callMXSEntryEx1")
            # give up lock, let Ex2 could exec codes
            locker.release()
            if not evt.wait(tick):
                pymxs.print_("Error: event untiggered\nwhich indicates 'with block' in Ex2 haven't finished\n", True, True)
            counter = 30
    except:
        pymxs.print_("Error: unexpected exception\n", True, True)
        raise
    finally:
        if locker.locked():
            locker.release()

def callMXSEntryEx2(locker, tick, evt):
    global flag, counter
    while flag:
        time.sleep(tick)

    try:
        locker.acquire()
        # we expected this block is finished
        # before Ex1 wakeup from sleep
        for i in xrange(10):
            # only a indicator, could just assign counter = 10
            counter = counter + 1
        evt.set()
        with pymxs.mxstoken():
            # this block won't be executed after Ex1 with block finished
            pymxs.runtime.Teapot(Name="callMXSEntryEx2")
            if counter != 30:
                pymxs.print_("Error: expected counter 30, got %d\nwhich indicates 'with block' in Ex2 haven't finished\n" % counter, True, True)
    except:
        raise
    finally:
        if locker.locked():
            locker.release()
    pymxs.print_("succss", False, True)

def main():
    locker = threading.Lock()
    evt = threading.Event()
    t1 = threading.Thread(target=callMXSEntry)
    t2 = threading.Thread(target=callMXSEntryEx1, args=(locker, 1, evt))
    t3 = threading.Thread(target=callMXSEntryEx2, args=(locker, 0.01, evt))
    t1.start()
    t2.start()
    t3.start()

if __name__ == "__main__":
    main()
