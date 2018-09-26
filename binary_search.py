def binary_search(items, n):
    """
    Search for n in items using binary search

    :param items: The input sequence that will be used for searching
    :param n: The item to search for
    :return: The item's index if found, None otherwise
    """
    left = 0
    right = len(items) - 1

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


my_list = [15, 44, 89, 218, 410, 524, 1051]
for x in (410, 314):
    x_position = binary_search(items=my_list, n=x)
    if x_position:
        print('{} found at position {}'.format(x, x_position))
    else:
        print('{} not found'.format(x))
