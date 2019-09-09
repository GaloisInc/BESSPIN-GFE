#!/usr/bin/env python3

"""Reset the gfe using the soft reset component
"""

from gfetester import gfetester

def reset_gfe():
    gfe = gfetester()
    gfe.startGdb()
    try:
        gfe.softReset()
    except Exception:
        print(gfe.getGdbLog())
        raise

if __name__ == '__main__':
    reset_gfe()
