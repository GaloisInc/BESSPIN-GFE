#!/usr/bin/env python3
import sys
import json
from collections import namedtuple
from subprocess import run, check_call
import os

Input = namedtuple('Input', 'sz h data num')

INPUT = Input(**dict(
    map(
        lambda parts: (parts[0], json.loads(parts[1])),
        map(
            lambda x: x.split(': '),
            filter(
                lambda x: x != '',
                map(lambda x: x.strip().replace('\n', ''),
                    sys.stdin.read().split('  ')))))))

print('CRYPTOL:')
print('    SHA256Final {h = %r, block = %r, n = %d, sz = %d}' %
      (INPUT.h, INPUT.data, INPUT.num, INPUT.sz))

print()

print('C:')
run([
    'gcc', '-xc', '-', '-o', '/tmp/sha-helper', '-g', '-m32', '--std=c11',
    '-I.'
],
    check=True,
    input=('''
#include "sha_256.c"
#include <stdio.h>

int main() {
    uint8_t out[SHA256_DIGEST_LENGTH];
    struct SHA256state_st state = {
        .sz = %dull,
        .h = {%s},
        .data = {%s},
        .num = %d
    };
    SHA256_Final(out, &state);
    for(int i=0;i<SHA256_DIGEST_LENGTH; i++) {
        printf("%%02x", (unsigned) out[i]);
    }
    printf("\\n");
    return 0;
}

''' % (INPUT.sz, ','.join(str(x) for x in INPUT.h), ','.join(
        str(x) for x in INPUT.data), INPUT.num)).encode('ascii'),
    cwd=os.path.dirname(__file__))
check_call(['/tmp/sha-helper'])
