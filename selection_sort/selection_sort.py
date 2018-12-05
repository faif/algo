def selection_sort(items):
    """
    Sort items using selection sort

    :param items: The input sequence (remains unmodified)
    :return: A sorted list with the same contents as items
    """
    sorted_items, items_copy = list(), list(items)
    for _ in range(len(items)):
        min_idx = min_index(items=items_copy)
        sorted_items.append(items_copy.pop(min_idx))
    return sorted_items


def min_index(items):
    """
    Return the index of the minimum element in items

    :param items: The input sequence
    :return: The minimum item index if the sequence has any items (int); None otherwise
    """
    if not items:
        return None

    if len(items) == 1:
        return 0

    min_item, min_idx = items[0], 0

    for i in range(1, len(items)):
        if items[i] < min_item:
            min_item, min_idx = items[i], i

    return min_idx


my_items = (19, 14, -5, 28, 93, 4, 7)
print('my_items: {}'.format(my_items))
my_sorted_items = selection_sort(items=my_items)
print('my_sorted_items: {}'.format(my_sorted_items))
