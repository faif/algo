def my_max(items):
    """
    Return the max element in items. Note that this
    function already exists in Python with the name max

    :param items: The input sequence
    :return: 0 if items is empty; int otherwise
    """
    if len(items) == 0:
        return 0

    def nmax(nitems, cur_max):
        if len(nitems) == 0:
            return cur_max
        elif nitems[0] > cur_max:
            cur_max = nitems[0]
        return nmax(nitems[1:], cur_max)

    current_max = items[0]
    return nmax(items, current_max)


my_items = (10, 5, 18, 4)
print('my_items: {}'.format(my_items))
print("Max of my_items = {}".format(my_max(items=my_items)))
