#!/usr/bin/env python3

"""Reset the gfe using the soft reset component
"""

import gfetester

gfe = gfetester.gfetester()
gfe.startGdb()
try:
	gfe.softReset()
except Exception as e:
	print((gfe.getGdbLog()))
