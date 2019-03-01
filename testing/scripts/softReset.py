#!/usr/bin/env python
"""Reset the gfe using the soft reset component
"""

import gfetester

gfe = gfetester.gfetester()
gfe.startGdb()
gfe.softReset()
