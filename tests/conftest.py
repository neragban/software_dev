"""Pytest configuration and fixtures."""

import os
import sys

# Add parent directory to path to import the scanner module
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
