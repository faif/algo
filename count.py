def count(items):
    """
    Count the number of elements in items (recursive version). Note that this
    function already exists in Python with the name len

    :param items: The input sequence
    :return: 0 if items is empty; int otherwise
    """
    if len(items) == 0:
        return 0
    return 1 + count(items[1:])


my_items = ('hello', 'world', 'foo')
print('my_items: {}'.format(my_items))
n_items = count(items=my_items)
print('Count of my_items = {}'.format(n_items))
