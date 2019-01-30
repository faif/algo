def set_covering(full_set, connections):
    """
    Solve the set-covering problem

    :param full_set: the initial complete set of items (set); modified in-place
    :param connections: the connections of each item (dict); modified in-place
    :return: the best items if a solution is found (set); empty set otherwise
    """
    picked_items = set()
    while full_set:
        best_item, items_covered = None, set()
        for item, item_connections in connections.items():
            covered = full_set.intersection(item_connections)
            if len(covered) > len(items_covered):
                best_item, items_covered = item, covered
        full_set -= items_covered
        picked_items.add(best_item)
    return picked_items


people = {'nick', 'mary', 'peter', 'helen', 'jim', 'eva', 'jill', 'george'}

friends = {
    'nick': {'peter', 'jim', 'george'},
    'mary': {'helen', 'jim', 'eva'},
    'peter': {'nick', 'eva', 'helen'},
    'helen': {'mary', 'eva', 'jill'},
    'jim': {'nick', 'mary'},
    'eva': {'mary', 'peter', 'helen', 'jill'},
    'jill': {'helen', 'eva'},
    'george': {'nick'}
}

clique = set_covering(full_set=people, connections=friends)
if clique:
    print('Largest clique of people: {}'.format(clique))
else:
    print('No clique of people found')
