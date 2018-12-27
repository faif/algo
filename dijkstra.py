def dijkstra(graph, costs, node_parents):
    """
    Apply Dijkstra's algorithm on graph

    :param graph: the graph to apply the algorithm on (dict)
    :param costs: the initial known costs (dict)
    :param node_parents: the initial known parents (dict)
    :return: the final costs and the calculated parents (tuple)
    """
    processed = list()
    node = lowest_cost_node(costs, processed)
    while node:
        cost = costs[node]
        neighbors = graph[node]
        for neighbor in neighbors.keys():
            new_cost = cost + neighbors[neighbor]
            if costs[neighbor] > new_cost:
                costs[neighbor] = new_cost
                node_parents[neighbor] = node
        processed.append(node)
        node = lowest_cost_node(costs, processed)
    return costs, node_parents


def lowest_cost_node(items, processed):
    """
    Get the name of the minimum cost non-processed node

    :param items: the nodes with their weights (dict)
    :param processed: the names of the nodes that have already been processed (tuple)
    :return: the name of the lowest cost node if found (str); None otherwise
    """
    lowest_cost, lowest_cost_n = float('inf'), None
    for n in items:
        n_cost = items[n]
        if n_cost < lowest_cost and n not in processed:
            lowest_cost, lowest_cost_n = n_cost, n
    return lowest_cost_n


def make_path(node_parents, end_point):
    """
    Get the path of 'Start' -> end_point (if any)

    :param node_parents: the nodes with their parents (dict)
    :param end_point: the destination node (str)
    :return: a sorted tuple of 'Start' -> end_point if applicable; empty tuple otherwise
    """
    the_path, n = list(), end_point
    while n != 'Start':
        the_path.append(n)
        n = node_parents[n]
    the_path.append('Start')
    return tuple(the_path[::-1])


# https://cdn-images-1.medium.com/max/1200/1*lzYuC6dIVTVl0gt3MOuCyw.jpeg
routes = {
    'Start': {'A': 5, 'B': 2},
    'A': {'C': 4, 'D': 2},
    'B': {'A': 8, 'D': 7},
    'C': {'Finish': 3, 'D': 6},
    'D': {'Finish': 1},
    'Finish': {}
}

infinity = float('inf')
distances = {
    'A': 5, 'B': 2, 'C': infinity, 'D': infinity, 'Finish': infinity
}

parents = {
    'A': 'Start',
    'B': 'Start'
}

route_costs, final_parents = dijkstra(graph=routes, costs=distances, node_parents=parents)
destination = 'Finish'
if destination in route_costs:
    print('Total cost of Start -> {} = {}'.format(destination, route_costs[destination]))
    path = make_path(node_parents=final_parents, end_point=destination)
    print('Path of Start -> {} = {}'.format(destination, path))
else:
    print('No path found for Start -> {}'.format(destination))
