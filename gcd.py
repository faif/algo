gcd_cache = dict()

def gcd_ef(m, n):
    assert m > 0 and n > 0, 'all inputs must be > 0'
    if m < n:
        m, n = n, m
    r = m % n
    if r == 0:
        return n
    m, n = n, r
    key = m + n
    if key in gcd_cache:
        return gcd_cache[key]
    result = gcd_ef(m, n)
    gcd_cache[key] = result
    return result

def gcd(m, n):
    assert m > 0 and n > 0, 'all inputs must be > 0'
    if m < n:
        m, n = n, m
    r = m % n
    if r == 0:
        return n
    m, n = n, r
    return gcd(m, n)

def gcd_min_vars(m, n):
    assert m > 0 and n > 0, 'all inputs must be > 0'
    m = m % n
    if m == 0:
        return n
    n = n % m
    if n == 0:
        return m
    return gcd_min_vars(m, n)

if __name__ == '__main__':
    from timeit import Timer
    m, n = 119, 544
    t = Timer('gcd({}, {})'.format(m, n), 'from __main__ import gcd')
    print('gcd({}, {}) = {}, duration: {}'.format(m, n, gcd(m, n), t.timeit()))
    t = Timer('gcd_ef({}, {})'.format(m, n), 'from __main__ import gcd_ef')
    print('gcd_ef({}, {}) = {}, duration: {}'.format(m, n, gcd_ef(m, n), t.timeit()))
    t = Timer('gcd_min_vars({}, {})'.format(m, n), 'from __main__ import gcd_min_vars')
    print('gcd_min_vars({}, {}) = {}, duration: {}'.format(m, n, gcd_min_vars(m, n), t.timeit()))
