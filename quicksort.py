import random


def quicksort(items):
    """
    Sort items using quicksort

    :param items: The input sequence
    :return: A sorted tuple with the same contents as items
    """
    if len(items) < 2:
        return items
    pivot = random.choice(items)
    smaller = tuple(i for i in items if i <= pivot)
    greater = tuple(i for i in items if i > pivot)
    return quicksort(smaller) + quicksort(greater)


my_items = (19, 14, -5, 28, 0, 93, 4, 7)
print('my_items: {}'.format(my_items))
my_sorted_items = quicksort(items=my_items)
print('my_sorted_items: {}'.format(my_sorted_items))
