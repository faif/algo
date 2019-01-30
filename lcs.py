def longest_common_subsequence(str1, str2):
    """
    Calculate the longest common subsequence of two strings

    :param str1: the first string (str)
    :param str2: the second string (str)
    :return: the longest common subsequence (int); 0 if no subsequence is found
    """
    grid = [[0 for _ in range(len(str2) + 1)] for _ in range(len(str1) + 1)]

    for index_row, item_row in enumerate(str1):
        for index_column, item_column in enumerate(str2):
            if item_row == item_column:
                grid[index_row + 1][index_column + 1] = grid[index_row][index_column] + 1
            else:
                grid[index_row + 1][index_column + 1] = max(grid[index_row + 1][index_column],
                                                            grid[index_row][index_column + 1])
    return grid[-1][-1]


word1, word2 = 'AGGTAB', 'GXTXAYB'
lcs = longest_common_subsequence(str1=word1, str2=word2)
print('Longest common subsequence of {} and {} = {}'.format(word1, word2, lcs))
