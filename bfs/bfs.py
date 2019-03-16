from collections import deque


def bfs(graph, start, end):
    """
    Search for a path in graph from start -> end

    :param graph: the graph to search (dict)
    :param start: the starting node (str)
    :param end: the ending node (str)
    :return: list of nodes if a path is found; None otherwise
    """
    if start not in graph:
        raise RuntimeError('Unknown start node: {}'.format(start))
    search_queue = deque()
    search_queue += graph[start]
    searched = [start]
    while search_queue:
        item = search_queue.popleft()
        if item not in searched:
            searched.append(item)
            if item == end:
                return searched
            search_queue += graph[item]
    return None


# treat https://upload.wikimedia.org/wikipedia/commons/a/ad/MapGermanyGraph.svg as a DAG
cities = {
    'Frankfurt': ['Mannheim', 'Wurzburg', 'Kassel'],
    'Mannheim': ['Karlsruhe'],
    'Karlsruhe': ['Augsburg'],
    'Augsburg': ['Munchen'],
    'Wurzburg': ['Erfurt', 'Nurnberg'],
    'Nurnberg': ['Stuttgart', 'Munchen'],
    'Kassel': ['Munchen'],
    'Erfurt': [],
    'Stuttgart': [],
    'Munchen': []
}

beginning, destination = 'Frankfurt', 'Munchen'
path = bfs(graph=cities, start=beginning, end=destination)
if path:
    print('Number of hops of {} -> {} ='.format(beginning, destination), len(path))
    print('Path of {} -> {}'.format(beginning, destination), path)
else:
    print('No path found for {} -> {}'.format(beginning, destination))
