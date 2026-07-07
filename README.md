# Xen CPUTop

[![License: AGPL v3](https://img.shields.io/badge/License-AGPLv3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0.en.html) 

## Description

This is a `bash` script that uses `awk` to parse the output of `xenpm start`, generating a list of cores and their utilizations. It also formats the percentages with colours for readability. The listed values are for *all* active CPU cores on the system, not just ones assigned to `dom0`.

## Usage

1. Copy this script to your `dom0`.
2. Launch it.

```
Usage:  xen-cputop.sh: [-h] [-d NUMBER] [-u REGEX] [-c NUMBER] [-n]

Options:
  -h, --help               print this usage information
  -d, --delay              refresh delay in seconds
  -u, --underline-cores    regex indicating which CPU cores to underline.
                           For example: -u '[0-7]|1[6-9]' will underline cores
                           0-7 and 16-19, so the p-cores on an Ultra 7 155H
  -c, --columns            number of columns to use for display
  -n, --no-totals          don't print the TOTAL row
```

## Screenshots

## Other Utilities

See [the qubes-utils repo](https://github.com/Atrate/qubes-utils) for links to other utilities I've written for Qubes.

## License
This project is licensed under the [AGPL-3.0-or-later](https://www.gnu.org/licenses/agpl-3.0.html).

[![License: AGPLv3](https://www.gnu.org/graphics/agplv3-with-text-162x68.png)](https://www.gnu.org/licenses/agpl-3.0.html)
