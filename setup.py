#! /usr/bin/env python
from ez_setup import use_setuptools
use_setuptools()
from setuptools import setup, find_packages
from pylamb import __version__


setup(name='ILAMB',
      version=__version__,
      author='Mark Piper',
      author_email='mark.piper@colorado.edu',
      description='Python BMI for ILAMB',
      long_description=open('README.md').read(),
      packages=find_packages(),
      scripts=[
          'scripts/run_ilamb.sh'
          ],
)
