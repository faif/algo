def my_sum(items):
    """
    Sum the elements in items (recursive version). Note that this
    function already exists in Python with the name sum

    :param items: The input sequence
    :return: 0 if items is empty; int otherwise
    """
    if len(items) == 0:
        return 0
    return items[0] + my_sum(items[1:])


my_items = (10, 5)
print('my_items: {}'.format(my_items))
print("Sum of my_items = {}".format(my_sum(my_items)))
