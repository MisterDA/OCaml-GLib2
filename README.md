[![Build Status](https://github.com/cedlemo/OCaml-GLib2/actions/workflows/main.yml/badge.svg?branch=master)](https://github.com/cedlemo/OCaml-GLib2/actions)
[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

# OCaml-GLib2

Autogenerated OCaml bindings of the GLib2 library based on Ctypes.

## Dependencies

This library relies on the OCaml package gobject-instropection:
```
opam install gobject-introspection
```

and on a bindings generator:

```
opam pin add --yes gi-bindings-generator https://github.com/cedlemo/OCaml-GI-ctypes-bindings-generator.git
```

## Clone and test

The idea is to generate the bindings and to compile the library

```
git clone https://github.com/cedlemo/OCaml-GLib2
cd OCaml-GLib2
dune exec generator/gen.exe
dune run test --profile=release
```
