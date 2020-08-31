#!/usr/bin/python3

"""
Script to test if we are in a virtual environment.
This is not perfect and will undoubtably break with new versions but appears
to work with current Python version.

Exit code is 0 if we are in a venv or 1 if not.
"""

import sys
import os

def is_venv():
    return (hasattr(sys, 'real_prefix') or
            (hasattr(sys, 'base_prefix') and sys.base_prefix != sys.prefix))

if is_venv() or "VIRTUAL_ENV" in os.environ:
  sys.exit(0)
sys.exit(1)
