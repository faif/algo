def binary_search(items, n):
    """
    Search for n in items using binary search

    :param items: The input sequence that will be used for searching
    :param n: The item to search for (int)
    :return: The item's index if found (int); None otherwise
    """
    left, right = 0, len(items) - 1

    while left <= right:
        middle = (left + right) // 2
        guess = items[middle]
        if guess == n:
            return middle
        elif guess > n:
            right = middle - 1
        else:
            left = middle + 1

    return None


def binary_search_recursive(items, n):
    """
    Search for n in items using binary search (recursive version)

    :param items: The input sequence that will be used for searching
    :param n: The item to search for (int)
    :return: The item's index if found (int); None otherwise
    """
    def bin_search(left_index, right_index):
        if left_index > right_index:
            return None
        middle = (left_index + right_index) // 2
        guess = items[middle]
        if guess == n:
            return middle
        elif guess > n:
            right_index = middle - 1
        else:
            left_index = middle + 1
        return bin_search(left_index, right_index)

    left, right = 0, len(items) - 1
    return bin_search(left, right)


my_items = (15, 44, 89, 218, 410, 524, 1051)
print('my_items: {}'.format(my_items))
for x in (410, 314, 1051):
    x_position = binary_search(items=my_items, n=x)
    if x_position:
        print('{} found at position {}'.format(x, x_position))
    else:
        print('{} not found'.format(x))
