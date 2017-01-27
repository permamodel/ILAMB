# ILAMB

The NCL source code for the [ILAMB](http://ilamb.org) (v1) benchmarking toolkit.

Note that this is not an official ILAMB source repository;
it's a just a local copy of
[CODES_1.4.5](http://redwood.ess.uci.edu/mingquan/www/ILAMB/CODES.AllVersions/CODES_1.4.5/CODES/)
for our [permamodel](https://github.com/permamodel)
group to experiment with.
This is the version of ILAMB that was presented
at the 2015 AGU Fall Meeting.


## Installation

I've written a Python BMI
that calls a bash script
that runs the NCL version of ILAMB.
The run script contains hardcoded paths
to the locations of NCL, ImageMagick, and ILAMB on ***beach***,
as well as the locations of the CMIP5 and MsTMIP model outputs
and benchmark datasets on the data store.
So this really only works on ***beach***.

Clone and install into a Python distribution with

    $ git clone https://github.com/permamodel/ILAMB
    $ cd ILAMB
    $ python setup.py install

Setuptools installs the run script **ilamb1-run**
into the **bin/** directory of the Python distribution.


## Use

In a Python session on ***beach***, execute:

```python
from pylamb import BmiIlamb as ILAMB

x = ILAMB()
x.initialize('/path/to/ILAMB_PARA_SETUP')
x.update()  # calls run script
x.finalize()
```

You can provide your own customized ILAMB parameter setup file
with either an absolute or a relative path.
A sample parameter setup file
can be found in the **examples/** directory
of this repository.

The result:
```bash
$ ls -F
ILAMB-output/  ILAMB_PARA_SETUP  ILAMB.stderr  ILAMB.stdout  ILAMB-tmp/
```

Display ILAMB's graphical output with a web browser:

    $ firefox ILAMB-output/www/ilamb.html

