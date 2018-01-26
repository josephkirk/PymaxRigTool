'''
    Demonstrates how to interoperate corresponding MAXScript types from Python and vice versa
'''
import MaxPlus
from pymxs import runtime as rt


def _ShowPyObject(obj):
    print type(obj), obj,


def _ShowMXSObject(obj):
    print repr(obj),


def _RunMXS(code_buff):
    import textwrap
    for line in textwrap.dedent(code_buff).split('\n'):
        if line:
            MaxPlus.Core.EvalMAXScript(line)


def CreateArray():
    arr = rt.Array(*range(3))
    _ShowMXSObject(arr)
    print

    return arr


def IterateArray(arr):
    for i in arr:
        _ShowMXSObject(i)
    print


def IndexArray(arr):
    first_elem = arr[0]
    _ShowMXSObject(first_elem)
    last_elem = arr[-1]
    _ShowMXSObject(last_elem)
    print


def ManipulateArray(arr):
    rt.append(arr, "foo")
    _ShowMXSObject(arr)
    rt.deleteItem(arr, arr.count)
    print


def ArrayToList(arr):
    arr_as_list = list(arr)
    _ShowPyObject(arr_as_list)
    print

    return arr_as_list


def ArrayToTuple(arr):
    arr_as_tuple = tuple(arr)
    _ShowPyObject(arr_as_tuple)
    print

    return arr_as_tuple


def ListToArray(list_obj):
    arr = rt.Array(*list_obj)
    _ShowMXSObject(arr)
    print

    return arr


def TupleToArray(tuple_obj):
    arr = rt.Array(*tuple_obj)
    _ShowMXSObject(arr)
    print

    return arr


def ArrayInterop():
    print "#Create Array:"
    arr = CreateArray()

    print "#Iterate Array:"
    IterateArray(arr)

    print "#Index Array:"
    IndexArray(arr)

    print "#Manipulate Array"
    ManipulateArray(arr)

    print "#Array to Lit:"
    arr_as_list = ArrayToList(arr)

    print "#Array to Tuple:"
    arr_as_tuple = ArrayToTuple(arr)

    print "#List to Array:"
    list_as_arr = ListToArray(arr_as_list)

    print "#Tuple To Array:"
    tuple_as_arr = TupleToArray(arr_as_tuple)


def CreateBitArray():
    barr = rt.BitArray(1, 3, rt.Name("range"), 5, 7)
    _ShowMXSObject(barr)
    print

    return barr


def IterateBitArray(barr):
    for i in barr:
        _ShowMXSObject(i)
    print


def IndexBitArray(barr):
    first_elem = barr[0]
    _ShowMXSObject(first_elem)
    last_elem = barr[-1]
    _ShowMXSObject(last_elem)
    print


def ManipulateBitArray(barr):
    barr[1] = True
    barr[-2] = True
    _ShowMXSObject(barr)
    barr[1] = False
    barr[-2] = False
    print


def BitArrayInterop():
    print "#Create BitArray"
    barr = CreateBitArray()

    print "#Iterate BitArray"
    IterateBitArray(barr)

    print "#Index BitArray"
    IndexBitArray(barr)

    print "#Manipulate BitArray"
    ManipulateBitArray(barr)


def ImportPythonInMXS():
    return r"""
    bi = python.import "__builtin__"
    """


def CreateListInMXS():
    return r"""
    my_list = bi.list #(1, 2, 3)
    format "% %\n" (bi.type my_list) my_list
    """


def CreateTupleInMXS():
    return r"""
    my_tuple = bi.tuple #(4, 5, 6)
    format "% %\n" (bi.type my_tuple) my_tuple
    """


def IndexListInMXS():
    return r"""
    format "% %\n" my_list[1] my_list[bi.len(my_list)]
    """


def IndexTupleInMXS():
    return r"""
    format "% %\n" my_Tuple[1] my_Tuple[bi.len(my_tuple)]
    """


def ManipulateListInMXS():
    return r"""
    my_list.append(my_tuple)
    format "%\n" (my_list as string)
    my_list.pop()
    """


def ListToArrayInMXS():
    return r"""
    list_as_arr = my_list as array
    format "% %\n" (classof list_as_arr) list_as_arr
    """


def TupleToArrayInMXS():
    return r"""
    tuple_as_arr = my_tuple as array
    format "% %\n" (classof tuple_as_arr) tuple_as_arr
    """


def ListInteropInMXS():
    print "#Create List:"
    _RunMXS(CreateListInMXS())

    print "#Index List:"
    _RunMXS(IndexListInMXS())

    print "#Manipulate List:"
    _RunMXS(ManipulateListInMXS())

    print "#List to Array:"
    _RunMXS(ListToArrayInMXS())


def TupleInteropInMXS():
    print "#Create Tuple:"
    _RunMXS(CreateTupleInMXS())

    print "#Index Tuple:"
    _RunMXS(IndexTupleInMXS())

    print "#Tuple to Array:"
    _RunMXS(TupleToArrayInMXS())


def CreateDictInMXS():
    return r"""
    my_dict = bi.dict a:1 b:2 c:3
    format "% %\n" (bi.type my_dict) my_dict
    """


def ManipulateDictInMXS():
    return r"""
    my_dict["d"] = 4
    format "%\n" (my_dict as string)
    my_dict.__delitem__("d")
    """


def DictInteropInMXS():
    print "#Create Dict:"
    _RunMXS(CreateDictInMXS())

    print "#Manipulate Dict:"
    _RunMXS(ManipulateDictInMXS())


def main():
    _RunMXS(ImportPythonInMXS())
    ArrayInterop()
    BitArrayInterop()
    ListInteropInMXS()
    TupleInteropInMXS()
    DictInteropInMXS()


if __name__ == '__main__':
    main()
