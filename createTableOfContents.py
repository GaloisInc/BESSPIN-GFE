#! /usr/bin/env python3

# Output a table of contents for the given Markdown file.
# Doesn't do anything to ignore #-prefixed lines in ``` code blocks.

from sys import argv

md_file = open(argv[1])

def sanitize(a_string):
    for char in './+-()': # and other url-unfriendly chars...
        a_string = a_string.replace(char, ' ')
    a_string = a_string.lower()
    return '-'.join(a_string.split()) 

for line in md_file:
    if line.startswith('#'):
        level, headline = line.split(' ', 1)
        level = level.count('#')
        headline = headline.rstrip('# \n')
        anchor = sanitize(headline)
        anchor = '-'.join(anchor.split())
        print('{}-[{}](#{})'.format(
            '  ' * (level - 1), headline, anchor))
