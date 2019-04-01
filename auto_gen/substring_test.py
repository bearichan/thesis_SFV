import sys
import re


def find_all(a_str, sub):
    start = 0
    while True:
        start = a_str.find(sub, start)
        if start == -1: return
        yield start
        start += len(sub) # use start += 1 to find overlapping matches

# list(find_all('spam spam spam spam', 'spam')) # [0, 5, 10, 15]

def locations_of_substring(string, substring):
    """Return a list of locations of a substring."""

    substring_length = len(substring)    
    def recurse(locations_found, start):
        location = string.find(substring, start)
        if location != -1:
            return recurse(locations_found + [location], location+substring_length)
        else:
            return locations_found

    return recurse([], 0)

if __name__ == '__main__':
    #print(locations_of_substring('hello my dear dogdog', 'dog'))
    print(find_all('spam spam spam spam', 'spam')) # [0, 5, 10, 15]
